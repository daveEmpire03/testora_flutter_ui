import { createMiddleware } from "hono/factory";
import type { Context } from "hono";

import type { AppEnv } from "../../config/environment";
import { verifyFirebaseIdToken } from "../../infrastructure/firebase/firebase-id-token-verifier";
import {
  FirebaseVerificationUnavailableError,
  InvalidFirebaseIdTokenError,
  type FirebaseTokenVerifier,
} from "./auth.types";

function unauthorized(c: Context<AppEnv>) {
  return c.json(
    {
      error: {
        code: "UNAUTHENTICATED",
        message: "A valid authentication token is required.",
      },
      requestId: c.get("requestId"),
    },
    401,
  );
}

export function createFirebaseAuthMiddleware(
  verifier: FirebaseTokenVerifier = verifyFirebaseIdToken,
) {
  return createMiddleware<AppEnv>(async (c, next) => {
    const authorization = c.req.header("Authorization");
    const match = authorization
      ? /^Bearer\s+([A-Za-z0-9._~-]+)$/i.exec(authorization.trim())
      : null;
    const token = match?.[1];

    if (!token || token.length > 8192) {
      return unauthorized(c);
    }

    const projectId = c.env.FIREBASE_PROJECT_ID?.trim();

    if (!projectId) {
      return c.json(
        {
          error: {
            code: "AUTH_PROVIDER_UNAVAILABLE",
            message: "Authentication service is not configured.",
          },
          requestId: c.get("requestId"),
        },
        503,
      );
    }

    try {
      const authenticatedUser = await verifier(token, projectId);
      c.set("authenticatedUser", authenticatedUser);
    } catch (error) {
      if (error instanceof InvalidFirebaseIdTokenError) {
        return unauthorized(c);
      }

      if (error instanceof FirebaseVerificationUnavailableError) {
        console.error("Firebase token verification unavailable", {
          requestId: c.get("requestId"),
        });

        return c.json(
          {
            error: {
              code: "AUTH_PROVIDER_UNAVAILABLE",
              message: "Authentication service is temporarily unavailable.",
            },
            requestId: c.get("requestId"),
          },
          503,
        );
      }

      console.error("Unexpected Firebase authentication failure", {
        requestId: c.get("requestId"),
      });

      return c.json(
        {
          error: {
            code: "AUTH_PROVIDER_UNAVAILABLE",
            message: "Authentication service is temporarily unavailable.",
          },
          requestId: c.get("requestId"),
        },
        503,
      );
    }

    await next();
  });
}
