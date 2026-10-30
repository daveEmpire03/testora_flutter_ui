import { Hono } from "hono";

import type { AppEnv } from "../../config/environment";
import { AppError } from "../../shared/errors/app-error";
import { D1PaymentRepository } from "./infrastructure/d1-payment.repository";
import { PaystackClient } from "./infrastructure/paystack.client";
import type { PaymentGateway } from "./domain/payment.types";
import { applyVerifiedTransaction } from "./application/payment.service";

interface WebhookOptions {
  gatewayFactory?: (secretKey: string) => PaymentGateway;
}

interface PaystackWebhookPayload {
  event?: unknown;
  data?: {
    id?: unknown;
    reference?: unknown;
  };
}

function constantTimeHexEqual(expected: string, received: string): boolean {
  if (
    expected.length !== received.length ||
    expected.length !== 128 ||
    !/^[a-f0-9]+$/i.test(received)
  ) {
    return false;
  }

  let difference = 0;
  for (let index = 0; index < expected.length; index++) {
    difference |=
      expected.charCodeAt(index) ^ received.toLowerCase().charCodeAt(index);
  }

  return difference === 0;
}

async function verifyPaystackSignature(
  rawBody: ArrayBuffer,
  secret: string,
  signature: string,
): Promise<boolean> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-512" },
    false,
    ["sign"],
  );

  const digest = await crypto.subtle.sign("HMAC", key, rawBody);
  const expected = Array.from(new Uint8Array(digest))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");

  return constantTimeHexEqual(expected, signature);
}

export function createPaystackWebhookRoutes(options: WebhookOptions = {}) {
  const routes = new Hono<AppEnv>();
  const gatewayFactory =
    options.gatewayFactory ?? ((secret: string) => new PaystackClient(secret));

  routes.post("/paystack", async (c) => {
    const secret = c.env.PAYSTACK_SECRET_KEY?.trim();
    if (!secret) {
      throw new AppError(503, "PAYMENT_PROVIDER_UNAVAILABLE", "The payment service is not configured.");
    }

    const contentLength = Number(c.req.header("Content-Length") ?? "0");
    if (Number.isFinite(contentLength) && contentLength > 262_144) {
      throw new AppError(413, "WEBHOOK_TOO_LARGE", "The webhook payload is too large.");
    }

    const rawBody = await c.req.arrayBuffer();
    if (rawBody.byteLength > 262_144) {
      throw new AppError(413, "WEBHOOK_TOO_LARGE", "The webhook payload is too large.");
    }

    const signature = c.req.header("x-paystack-signature");
    if (!signature) {
      throw new AppError(401, "INVALID_WEBHOOK_SIGNATURE", "Webhook signature is invalid.");
    }

    const signatureIsValid = await verifyPaystackSignature(
      rawBody,
      secret,
      signature,
    );

    if (!signatureIsValid) {
      throw new AppError(401, "INVALID_WEBHOOK_SIGNATURE", "Webhook signature is invalid.");
    }

    let payload: PaystackWebhookPayload;
    try {
      payload = JSON.parse(new TextDecoder().decode(rawBody)) as PaystackWebhookPayload;
    } catch {
      throw new AppError(400, "INVALID_WEBHOOK_PAYLOAD", "Webhook payload is invalid.");
    }

    if (payload.event !== "charge.success") {
      return c.json({ received: true, processed: false });
    }

    const reference = payload.data?.reference;
    if (typeof reference !== "string" || !/^testora_[a-f0-9]{32}$/i.test(reference)) {
      return c.json({ received: true, processed: false });
    }

    if (!c.env.DB) {
      throw new AppError(503, "DATABASE_UNAVAILABLE", "The payment service is temporarily unavailable.");
    }

    const repository = new D1PaymentRepository(c.env.DB);
    const payment = await repository.findByReference(reference);

    // A valid Paystack event can arrive after a local record has been cleaned up.
    // Acknowledge unknown references without granting access.
    if (!payment) {
      console.warn("Paystack webhook received for an unknown reference", {
        requestId: c.get("requestId"),
      });
      return c.json({ received: true, processed: false });
    }

    const gateway = gatewayFactory(secret);
    try {
      const eventId =
        typeof payload.data?.id === "string" ||
        typeof payload.data?.id === "number"
          ? String(payload.data.id)
          : reference;

      const updated = await applyVerifiedTransaction(
        repository,
        payment,
        gateway,
        {
          webhookEventKey: "charge.success:" + eventId,
          webhookEventType: "charge.success",
        },
      );

      if (updated.status !== "success") {
        throw new Error("Paystack event did not verify as successful.");
      }
    } catch (error) {
      if (error instanceof AppError && error.status === 409) {
        console.error("Paystack webhook transaction mismatch", {
          requestId: c.get("requestId"),
          reference,
        });
        return c.json({ received: true, processed: false });
      }

      console.error("Paystack webhook processing failed", {
        requestId: c.get("requestId"),
        reference,
      });

      throw new AppError(
        503,
        "WEBHOOK_PROCESSING_FAILED",
        "The webhook could not be processed. Paystack may retry it.",
      );
    }

    return c.json({ received: true, processed: true });
  });

  return routes;
}
