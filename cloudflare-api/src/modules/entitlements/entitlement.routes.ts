import { Hono } from "hono";

import type { AppEnv } from "../../config/environment";
import { AppError } from "../../shared/errors/app-error";
import { createFirebaseAuthMiddleware } from "../auth/firebase-auth.middleware";
import type { FirebaseTokenVerifier } from "../auth/auth.types";
import { getPaymentPackage } from "../payments/domain/payment-catalog";
import { D1EntitlementsRepository } from "./entitlements.repository";

export function createEntitlementRoutes(verifier?: FirebaseTokenVerifier) {
  const routes = new Hono<AppEnv>();
  const authenticate = createFirebaseAuthMiddleware(verifier);

  routes.get("/", authenticate, async (c) => {
    if (!c.env.DB) {
      throw new AppError(503, "DATABASE_UNAVAILABLE", "The access service is temporarily unavailable.");
    }

    const user = c.get("authenticatedUser");
    const repository = new D1EntitlementsRepository(c.env.DB);
    const entitlements = await repository.listForUser(user.uid);

    return c.json({
      data: entitlements,
      requestId: c.get("requestId"),
    });
  });

  routes.get("/:packageId", authenticate, async (c) => {
    const packageId = c.req.param("packageId");
    if (!getPaymentPackage(packageId)) {
      throw new AppError(404, "PACKAGE_NOT_FOUND", "The exam package was not found.");
    }

    if (!c.env.DB) {
      throw new AppError(503, "DATABASE_UNAVAILABLE", "The access service is temporarily unavailable.");
    }

    const user = c.get("authenticatedUser");
    const repository = new D1EntitlementsRepository(c.env.DB);
    const entitled = await repository.hasActiveEntitlement(user.uid, packageId);

    return c.json({
      data: { packageId, entitled },
      requestId: c.get("requestId"),
    });
  });

  return routes;
}
