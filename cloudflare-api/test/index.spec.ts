import {
  createExecutionContext,
  waitOnExecutionContext,
} from "cloudflare:test";

import { describe, expect, it } from "vitest";
import worker from "../src/index";
import { createApp } from "../src/app";
import type { AppBindings } from "../src/config/environment";
import {
  InvalidFirebaseIdTokenError,
} from "../src/modules/auth/auth.types";
import { verifyFirebaseIdToken } from "../src/infrastructure/firebase/firebase-id-token-verifier";

const IncomingRequest = Request<unknown, IncomingRequestCfProperties>;

type TestApplication = {
  fetch(
    request: Request,
    env: AppBindings,
    context: ExecutionContext,
  ): Promise<Response>;
};

async function makeRequest(
  application: TestApplication,
  path: string,
  init: RequestInit = {},
  bindings: AppBindings = {},
): Promise<Response> {
  const request = new IncomingRequest(
    "https://testora.test" + path,
    init,
  );

  const context = createExecutionContext();
  const response = await application.fetch(request, bindings, context);
  await waitOnExecutionContext(context);

  return response;
}

const testUser = {
  uid: "firebase-user-from-verified-token",
  email: "student@example.com",
  emailVerified: true,
};

const authTestApp = createApp({
  firebaseTokenVerifier: async (token, projectId) => {
    if (projectId !== "test-project" || token !== "valid-test-token") {
      throw new InvalidFirebaseIdTokenError();
    }
    return testUser;
  },
});

describe("Testora API", () => {
  describe("Health endpoint", () => {
    it("returns HTTP 200", async () => {
      const response = await makeRequest(worker, "/api/v1/health");
      expect(response.status).toBe(200);
    });

    it("returns the correct service status", async () => {
      const response = await makeRequest(worker, "/api/v1/health");
      const body = (await response.json()) as {
        status: string;
        service: string;
        timestamp: string;
      };

      expect(body.status).toBe("ok");
      expect(body.service).toBe("testora-api");
      expect(Number.isNaN(Date.parse(body.timestamp))).toBe(false);
    });

    it("reports not ready when D1 is not bound", async () => {
      const response = await makeRequest(worker, "/api/v1/health/ready");
      expect(response.status).toBe(503);
    });
  });

  describe("Error handling", () => {
    it("returns a structured 404 for unknown routes", async () => {
      const response = await makeRequest(worker, "/api/v1/unknown");

      expect(response.status).toBe(404);
      expect(await response.json()).toMatchObject({
        error: {
          code: "NOT_FOUND",
          message: "The requested resource was not found.",
        },
      });
    });
  });

  describe("CORS", () => {
    it("allows requests from configured origins", async () => {
      const response = await makeRequest(
        worker,
        "/api/v1/health",
        { headers: { Origin: "https://testora.example" } },
        { ALLOWED_ORIGINS: "https://testora.example" },
      );

      expect(response.status).toBe(200);
      expect(response.headers.get("Access-Control-Allow-Origin"))
        .toBe("https://testora.example");
    });

    it("does not allow unconfigured origins", async () => {
      const response = await makeRequest(
        worker,
        "/api/v1/health",
        { headers: { Origin: "https://untrusted.example" } },
        { ALLOWED_ORIGINS: "https://testora.example" },
      );

      expect(response.status).toBe(200);
      expect(response.headers.get("Access-Control-Allow-Origin")).toBeNull();
    });
  });

  describe("Firebase authentication", () => {
    it("rejects a request without a bearer token", async () => {
      const response = await makeRequest(
        authTestApp,
        "/api/v1/auth/me",
        {},
        { FIREBASE_PROJECT_ID: "test-project" },
      );

      expect(response.status).toBe(401);
    });

    it("rejects malformed authorization headers", async () => {
      const response = await makeRequest(
        authTestApp,
        "/api/v1/auth/me",
        { headers: { Authorization: "Basic invalid-token" } },
        { FIREBASE_PROJECT_ID: "test-project" },
      );

      expect(response.status).toBe(401);
    });

    it("returns identity established by the token verifier", async () => {
      const response = await makeRequest(
        authTestApp,
        "/api/v1/auth/me",
        { headers: { Authorization: "Bearer valid-test-token" } },
        { FIREBASE_PROJECT_ID: "test-project" },
      );

      expect(response.status).toBe(200);
      expect(await response.json()).toMatchObject({
        user: {
          uid: testUser.uid,
          email: testUser.email,
          emailVerified: true,
        },
      });
    });

    it("rejects invalid tokens", async () => {
      const response = await makeRequest(
        authTestApp,
        "/api/v1/auth/me",
        { headers: { Authorization: "Bearer invalid-test-token" } },
        { FIREBASE_PROJECT_ID: "test-project" },
      );

      expect(response.status).toBe(401);
    });

    it("returns service unavailable when Firebase is not configured", async () => {
      const response = await makeRequest(
        authTestApp,
        "/api/v1/auth/me",
        { headers: { Authorization: "Bearer valid-test-token" } },
      );

      expect(response.status).toBe(503);
    });

    it("rejects malformed JWTs before making a key request", async () => {
      await expect(
        verifyFirebaseIdToken("not-a-jwt", "test-project"),
      ).rejects.toBeInstanceOf(InvalidFirebaseIdTokenError);
    });
  });

  describe("Paystack webhook", () => {
    it("rejects requests with an invalid signature", async () => {
      const response = await makeRequest(
        worker,
        "/api/v1/webhooks/paystack",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-paystack-signature": "a".repeat(128),
          },
          body: JSON.stringify({ event: "charge.success", data: {} }),
        },
        { PAYSTACK_SECRET_KEY: "test-secret" },
      );

      expect(response.status).toBe(401);
    });
  });
});
