export interface AppBindings {
  DB?: D1Database;
  APP_ENV?: "development" | "production" | "test";
  ALLOWED_ORIGINS?: string;
  FIREBASE_PROJECT_ID?: string;
  PAYSTACK_SECRET_KEY?: string;
  PAYSTACK_CALLBACK_URL?: string;
}

export interface AuthenticatedUser {
  uid: string;
  email?: string;
  emailVerified: boolean;
}

export interface AppEnv {
  Bindings: AppBindings;
  Variables: {
    authenticatedUser: AuthenticatedUser;
    requestId: string;
  };
}

export function parseAllowedOrigins(
  value: string | undefined,
): ReadonlySet<string> {
  if (!value) return new Set<string>();

  return new Set(
    value
      .split(",")
      .map((origin) => origin.trim())
      .filter(Boolean),
  );
}
