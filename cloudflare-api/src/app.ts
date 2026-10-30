import { Hono } from "hono";
import { cors } from "hono/cors";

import type { AppEnv } from "./config/environment";
import { parseAllowedOrigins } from "./config/environment";
import { AppError } from "./shared/errors/app-error";

import { createAuthRoutes } from "./modules/auth/auth.routes";
import type { FirebaseTokenVerifier } from "./modules/auth/auth.types";
import healthRoutes from "./modules/health/health.routes";
import { createPaymentRoutes } from "./modules/payments/payment.routes";
import { createPaystackWebhookRoutes } from "./modules/payments/webhook.routes";
import type { PaymentGateway } from "./modules/payments/domain/payment.types";
import { createEntitlementRoutes } from "./modules/entitlements/entitlement.routes";

interface CreateAppOptions {
  firebaseTokenVerifier?: FirebaseTokenVerifier;
  gatewayFactory?: (secretKey: string) => PaymentGateway;
}

export function createApp(options: CreateAppOptions = {}) {
  const app = new Hono<AppEnv>();

  app.use("*", async (c, next) => {
    const requestId = crypto.randomUUID();
    c.set("requestId", requestId);
    c.header("X-Request-Id", requestId);
    c.header("Cache-Control", "no-store");
    await next();
  });

  app.use(
    "*",
    cors({
      origin: (origin, c) => {
        if (!origin) return "";

        const allowedOrigins = parseAllowedOrigins(
          c.env.ALLOWED_ORIGINS,
        );

        return allowedOrigins.has(origin) ? origin : "";
      },
      allowMethods: ["GET", "POST", "PATCH", "DELETE", "OPTIONS"],
      allowHeaders: ["Content-Type", "Authorization"],
      exposeHeaders: ["X-Request-Id"],
      maxAge: 86400,
    }),
  );

  app.route("/api/v1/health", healthRoutes);
  app.route("/api/v1/auth", createAuthRoutes(options.firebaseTokenVerifier));
  app.route(
    "/api/v1/payments",
    createPaymentRoutes({
      firebaseTokenVerifier: options.firebaseTokenVerifier,
      gatewayFactory: options.gatewayFactory,
    }),
  );
  app.route(
    "/api/v1/entitlements",
    createEntitlementRoutes(options.firebaseTokenVerifier),
  );
  app.route(
    "/api/v1/webhooks",
    createPaystackWebhookRoutes({
      gatewayFactory: options.gatewayFactory,
    }),
  );

  app.notFound((c) => {
    return c.json(
      {
        error: {
          code: "NOT_FOUND",
          message: "The requested resource was not found.",
        },
        requestId: c.get("requestId"),
      },
      404,
    );
  });

  app.onError((error, c) => {
    if (error instanceof AppError) {
      if (error.status >= 500) {
        console.error("API request failed", {
          code: error.code,
          requestId: c.get("requestId"),
          method: c.req.method,
          path: c.req.path,
        });
      }

      return c.json(
        {
          error: {
            code: error.code,
            message: error.publicMessage,
          },
          requestId: c.get("requestId"),
        },
        error.status,
      );
    }

    console.error("Unhandled API error", {
      name: error.name,
      requestId: c.get("requestId"),
      method: c.req.method,
      path: c.req.path,
    });

    return c.json(
      {
        error: {
          code: "INTERNAL_SERVER_ERROR",
          message: "An unexpected error occurred.",
        },
        requestId: c.get("requestId"),
      },
      500,
    );
  });

  return app;
}

const app = createApp();

export default app;
