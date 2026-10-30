import { Hono } from "hono";

const healthRoutes = new Hono();

healthRoutes.get("/", (c) => {
  return c.json({
    status: "ok",
    service: "testora-api",
    timestamp: new Date().toISOString(),
  });
});

export default healthRoutes;
