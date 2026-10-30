import { Hono } from "hono";

import type { AppEnv } from "../../config/environment";

const healthRoutes = new Hono<AppEnv>();

healthRoutes.get("/", (c) => {
  return c.json({
    status: "ok",
    service: "testora-api",
    timestamp: new Date().toISOString(),
  });
});

healthRoutes.get("/ready", async (c) => {
  if (!c.env.DB) {
    return c.json(
      {
        status: "not_ready",
        service: "testora-api",
        reason: "database_binding_missing",
      },
      503,
    );
  }

  try {
    await c.env.DB.prepare("SELECT 1 AS ready").first();

    return c.json({
      status: "ready",
      service: "testora-api",
      timestamp: new Date().toISOString(),
    });
  } catch {
    return c.json(
      {
        status: "not_ready",
        service: "testora-api",
        reason: "database_unavailable",
      },
      503,
    );
  }
});

export default healthRoutes;
