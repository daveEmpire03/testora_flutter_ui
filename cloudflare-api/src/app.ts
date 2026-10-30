import { Hono } from "hono";
import { cors } from "hono/cors";

import type { AppBindings } from "./config/environment";
import { parseAllowedOrigins } from "./config/environment";
import healthRoutes from "./modules/health/health.routes";

const app = new Hono<{ Bindings: AppBindings }>();

app.use(
  "*",
  cors({
    origin: (origin, c) => {
      if (!origin) {
        return "";
      }

      const allowedOrigins = parseAllowedOrigins(
        c.env.ALLOWED_ORIGINS,
      );

      return allowedOrigins.has(origin) ? origin : "";
    },
    allowMethods: ["GET", "POST", "PATCH", "DELETE", "OPTIONS"],
    allowHeaders: ["Content-Type", "Authorization"],
    maxAge: 86400,
  }),
);

app.route("/api/v1/health", healthRoutes);

app.notFound((c) => {
  return c.json(
    {
      error: {
        code: "NOT_FOUND",
        message: "The requested resource was not found.",
      },
    },
    404,
  );
});

app.onError((error, c) => {
  console.error("Unhandled API error", {
    name: error.name,
    method: c.req.method,
    path: c.req.path,
  });

  return c.json(
    {
      error: {
        code: "INTERNAL_SERVER_ERROR",
        message: "An unexpected error occurred.",
      },
    },
    500,
  );
});

export default app;
