import {
  createExecutionContext,
  waitOnExecutionContext,
} from "cloudflare:test";

import { describe, expect, it } from "vitest";
import worker from "../src/index";

import type { AppBindings } from "../src/config/environment";

const IncomingRequest = Request<unknown, IncomingRequestCfProperties>;

async function makeRequest(
  path: string,
  init?: RequestInit,
  bindings: AppBindings = {},
): Promise<Response> {
  const request = new IncomingRequest(
    `https://testora.test${path}`,
    init,
  );

  const context = createExecutionContext();

  const response = await worker.fetch(request, bindings, context);

  await waitOnExecutionContext(context);

  return response;
}

describe("Testora API", () => {
  describe("Health endpoint", () => {
    it("returns HTTP 200", async () => {
      const response = await makeRequest("/api/v1/health");

      expect(response.status).toBe(200);
    });

    it("returns the correct service status", async () => {
      const response = await makeRequest("/api/v1/health");

      const body = (await response.json()) as {
        status: string;
        service: string;
        timestamp: string;
      };

      expect(body.status).toBe("ok");
      expect(body.service).toBe("testora-api");

      expect(Number.isNaN(Date.parse(body.timestamp))).toBe(false);
    });
  });

  describe("Error handling", () => {
    it("returns a structured 404 for unknown routes", async () => {
      const response = await makeRequest("/api/v1/unknown");

      const body = await response.json();

      expect(response.status).toBe(404);

      expect(body).toEqual({
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
        "/api/v1/health",
        {
          headers: {
            Origin: "https://testora.example",
          },
        },
        {
          ALLOWED_ORIGINS: "https://testora.example",
        },
      );

      expect(response.status).toBe(200);

      expect(
        response.headers.get("Access-Control-Allow-Origin"),
      ).toBe("https://testora.example");
    });

    it("does not allow unconfigured origins", async () => {
      const response = await makeRequest(
        "/api/v1/health",
        {
          headers: {
            Origin: "https://untrusted.example",
          },
        },
        {
          ALLOWED_ORIGINS: "https://testora.example",
        },
      );

      expect(response.status).toBe(200);

      expect(
        response.headers.get("Access-Control-Allow-Origin"),
      ).toBeNull();
    });
  });
});
