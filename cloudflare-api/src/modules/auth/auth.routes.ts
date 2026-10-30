import { Hono } from "hono";

import type { AppEnv } from "../../config/environment";
import { createFirebaseAuthMiddleware } from "./firebase-auth.middleware";
import type { FirebaseTokenVerifier } from "./auth.types";

export function createAuthRoutes(verifier?: FirebaseTokenVerifier) {
  const routes = new Hono<AppEnv>();

  routes.get(
    "/me",
    createFirebaseAuthMiddleware(verifier),
    (c) => {
      const user = c.get("authenticatedUser");

      return c.json({
        user: {
          uid: user.uid,
          email: user.email ?? null,
          emailVerified: user.emailVerified,
        },
        requestId: c.get("requestId"),
      });
    },
  );

  return routes;
}
