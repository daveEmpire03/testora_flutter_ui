export interface AppBindings {
  APP_ENV?: "development" | "production" | "test";
  ALLOWED_ORIGINS?: string;
}

export function parseAllowedOrigins(
  value: string | undefined,
): ReadonlySet<string> {
  if (!value) {
    return new Set<string>();
  }

  return new Set(
    value
      .split(",")
      .map((origin) => origin.trim())
      .filter(Boolean),
  );
}
