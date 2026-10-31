import { Hono } from "hono";

import type { AppEnv } from "../../config/environment";
import { AppError } from "../../shared/errors/app-error";
import { createFirebaseAuthMiddleware } from "../auth/firebase-auth.middleware";
import type { FirebaseTokenVerifier } from "../auth/auth.types";
import { getPaymentPackage } from "./domain/payment-catalog";
import type { PaymentGateway } from "./domain/payment.types";
import { D1PaymentRepository } from "./infrastructure/d1-payment.repository";
import { PaystackClient } from "./infrastructure/paystack.client";
import { applyVerifiedTransaction } from "./application/payment.service";

interface PaymentRouteOptions {
  firebaseTokenVerifier?: FirebaseTokenVerifier;
  gatewayFactory?: (secretKey: string) => PaymentGateway;
}

function requireDatabase(c: { env: AppEnv["Bindings"] }): D1Database {
  if (!c.env.DB) {
    throw new AppError(503, "DATABASE_UNAVAILABLE", "The payment service is not configured.");
  }
  return c.env.DB;
}

function requirePaystackSecret(c: { env: AppEnv["Bindings"] }): string {
  const secret = c.env.PAYSTACK_SECRET_KEY?.trim();
  if (!secret) {
    throw new AppError(503, "PAYMENT_PROVIDER_UNAVAILABLE", "The payment service is not configured.");
  }
  return secret;
}

function publicPayment(payment: {
  reference: string;
  packageId: string;
  amountKobo: number;
  currency: string;
  status: string;
  authorizationUrl: string | null;
  createdAt: string;
  paidAt: string | null;
}) {
  return {
    reference: payment.reference,
    packageId: payment.packageId,
    amount: payment.amountKobo,
    currency: payment.currency,
    status: payment.status,
    authorizationUrl: payment.authorizationUrl,
    createdAt: payment.createdAt,
    paidAt: payment.paidAt,
  };
}

export function createPaymentRoutes(options: PaymentRouteOptions = {}) {
  const routes = new Hono<AppEnv>();
  const authenticate = createFirebaseAuthMiddleware(
    options.firebaseTokenVerifier,
  );
  const gatewayFactory =
    options.gatewayFactory ?? ((secret: string) => new PaystackClient(secret));

  routes.post("/initialize", authenticate, async (c) => {
    const contentType = c.req.header("Content-Type") ?? "";
    if (!contentType.toLowerCase().includes("application/json")) {
      throw new AppError(400, "INVALID_CONTENT_TYPE", "Send a JSON request body.");
    }

    const rawBody = await c.req.text();
    if (rawBody.length > 4096) {
      throw new AppError(413, "REQUEST_TOO_LARGE", "The request body is too large.");
    }

    let body: unknown;
    try {
      body = JSON.parse(rawBody);
    } catch {
      throw new AppError(400, "INVALID_JSON", "The request body must contain valid JSON.");
    }

    if (
      body === null ||
      typeof body !== "object" ||
      Array.isArray(body) ||
      Object.keys(body).some((key) => key !== "packageId") ||
      typeof (body as Record<string, unknown>).packageId !== "string"
    ) {
      throw new AppError(400, "INVALID_REQUEST", "Provide only a valid packageId.");
    }

    const packageId = (body as { packageId: string }).packageId.trim();
    const paymentPackage = getPaymentPackage(packageId);

    if (!paymentPackage) {
      throw new AppError(422, "UNKNOWN_PACKAGE", "The selected exam package is not available.");
    }

    const user = c.get("authenticatedUser");
    const email = user.email?.trim();

    if (!email || email.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      throw new AppError(422, "EMAIL_REQUIRED", "Your Firebase account must have a valid email address.");
    }

    const db = requireDatabase(c);
    const secret = requirePaystackSecret(c);
    const repository = new D1PaymentRepository(db);
    const gateway = gatewayFactory(secret);
    const reference = "testora_" + crypto.randomUUID().replace(/-/g, "");
    const createdAt = new Date().toISOString();

    await repository.createInitializingPayment({
      reference,
      firebaseUid: user.uid,
      packageId: paymentPackage.id,
      amountKobo: paymentPackage.amountKobo,
      currency: paymentPackage.currency,
      customerEmail: email,
      createdAt,
    });

    try {
      const callbackUrl = c.env.PAYSTACK_CALLBACK_URL?.trim();
      if (callbackUrl) {
        const parsedCallback = new URL(callbackUrl);
        if (parsedCallback.protocol !== "https:") {
          throw new AppError(
            503,
            "PAYMENT_CALLBACK_MISCONFIGURED",
            "The payment callback URL must use HTTPS.",
          );
        }
      }

      const initialized = await gateway.initializeTransaction({
        email,
        amount: paymentPackage.amountKobo,
        currency: paymentPackage.currency,
        reference,
        callbackUrl: callbackUrl || undefined,
        metadata: {
          package_id: paymentPackage.id,
          application: "testora",
        },
      });

      if (initialized.reference !== reference) {
        throw new Error("Paystack returned a mismatched reference.");
      }

      await repository.attachCheckoutUrl(
        reference,
        initialized.authorizationUrl,
        new Date().toISOString(),
      );

      const payment = await repository.findByReference(reference);
      if (!payment) throw new Error("Payment record could not be reloaded.");

      return c.json(
        {
          data: publicPayment(payment),
          requestId: c.get("requestId"),
        },
        201,
      );
    } catch (error) {
      await repository.markFailed(reference, new Date().toISOString());

      if (error instanceof AppError) throw error;

      const errorMessage =
        error instanceof Error ? error.message : "Paystack initialization failed";

      console.error("Paystack initialization failed", {
        requestId: c.get("requestId"),
        reference,
        error: errorMessage,
      });

      throw new AppError(
        502,
        "PAYMENT_INITIALIZATION_FAILED",
        c.env.APP_ENV === "development"
          ? `Payment initialization failed: ${errorMessage}`
          : "We could not start your payment. Please try again.",
      );
    }
  });

  routes.get("/history", authenticate, async (c) => {
    const repository = new D1PaymentRepository(requireDatabase(c));
    const payments = await repository.listUserPayments(
      c.get("authenticatedUser").uid,
    );

    return c.json({
      data: payments.map(publicPayment),
      requestId: c.get("requestId"),
    });
  });

  routes.get("/:reference/status", authenticate, async (c) => {
    const reference = c.req.param("reference");
    if (!/^testora_[a-f0-9]{32}$/i.test(reference)) {
      throw new AppError(404, "PAYMENT_NOT_FOUND", "Payment was not found.");
    }

    const repository = new D1PaymentRepository(requireDatabase(c));
    const payment = await repository.findOwnedPayment(
      reference,
      c.get("authenticatedUser").uid,
    );

    if (!payment) {
      throw new AppError(404, "PAYMENT_NOT_FOUND", "Payment was not found.");
    }

    return c.json({
      data: publicPayment(payment),
      requestId: c.get("requestId"),
    });
  });

  routes.post("/:reference/verify", authenticate, async (c) => {
    const reference = c.req.param("reference");
    if (!/^testora_[a-f0-9]{32}$/i.test(reference)) {
      throw new AppError(404, "PAYMENT_NOT_FOUND", "Payment was not found.");
    }

    const repository = new D1PaymentRepository(requireDatabase(c));
    const payment = await repository.findOwnedPayment(
      reference,
      c.get("authenticatedUser").uid,
    );

    if (!payment) {
      throw new AppError(404, "PAYMENT_NOT_FOUND", "Payment was not found.");
    }

    if (payment.status === "success" || payment.status === "failed") {
      return c.json({
        data: publicPayment(payment),
        requestId: c.get("requestId"),
      });
    }

    const gateway = gatewayFactory(requirePaystackSecret(c));
    let updatedPayment;

    try {
      updatedPayment = await applyVerifiedTransaction(
        repository,
        payment,
        gateway,
      );
    } catch (error) {
      if (error instanceof AppError) throw error;

      console.error("Paystack verification request failed", {
        requestId: c.get("requestId"),
        reference,
        error: error instanceof Error ? error.message : String(error),
      });

      throw new AppError(
        503,
        "PAYMENT_VERIFICATION_UNAVAILABLE",
        "We could not verify this payment right now. Please try again.",
      );
    }

    return c.json({
      data: publicPayment(updatedPayment),
      requestId: c.get("requestId"),
    });
  });

  return routes;
}
