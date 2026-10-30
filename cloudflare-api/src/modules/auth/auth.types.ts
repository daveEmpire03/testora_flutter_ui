import type { AuthenticatedUser } from "../../config/environment";

export type FirebaseTokenVerifier = (
  token: string,
  projectId: string,
) => Promise<AuthenticatedUser>;

export class InvalidFirebaseIdTokenError extends Error {
  constructor() {
    super("Firebase ID token is invalid.");
    this.name = "InvalidFirebaseIdTokenError";
  }
}

export class FirebaseVerificationUnavailableError extends Error {
  constructor() {
    super("Firebase token verification is temporarily unavailable.");
    this.name = "FirebaseVerificationUnavailableError";
  }
}
