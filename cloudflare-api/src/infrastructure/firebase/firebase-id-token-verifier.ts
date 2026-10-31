import type { AuthenticatedUser } from "../../config/environment";
import {
  FirebaseVerificationUnavailableError,
  InvalidFirebaseIdTokenError,
} from "../../modules/auth/auth.types";

const FIREBASE_JWKS_URL =
  "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com";

interface FirebaseJwk extends JsonWebKey {
  /** Key identifier published by Google's JWKS endpoint. */
  kid?: string;
  alg?: string;
  use?: string;
}

interface FirebaseJwks {
  keys: FirebaseJwk[];
}

interface FirebaseJwtHeader {
  alg?: unknown;
  kid?: unknown;
  typ?: unknown;
  crit?: unknown;
}

interface FirebaseJwtPayload {
  aud?: unknown;
  iss?: unknown;
  sub?: unknown;
  exp?: unknown;
  iat?: unknown;
  auth_time?: unknown;
  email?: unknown;
  email_verified?: unknown;
}

interface CachedJwks {
  keys: FirebaseJwk[];
  expiresAt: number;
}

export interface FirebaseIdTokenVerifierOptions {
  /** Injectable for deterministic cryptographic tests. */
  fetcher?: typeof fetch;
  /** Clock returning milliseconds since the Unix epoch. */
  now?: () => number;
}

function decodeBase64Url(value: string): Uint8Array {
  if (!/^[A-Za-z0-9_-]+$/.test(value)) {
    throw new InvalidFirebaseIdTokenError();
  }

  const normalized = value.replace(/-/g, "+").replace(/_/g, "/");
  const padded = normalized.padEnd(
    normalized.length + ((4 - (normalized.length % 4)) % 4),
    "=",
  );

  try {
    const binary = atob(padded);
    return Uint8Array.from(binary, (character) => character.charCodeAt(0));
  } catch {
    throw new InvalidFirebaseIdTokenError();
  }
}

function decodeJsonSegment<T>(segment: string): T {
  try {
    const bytes = decodeBase64Url(segment);
    return JSON.parse(new TextDecoder().decode(bytes)) as T;
  } catch (error) {
    if (error instanceof InvalidFirebaseIdTokenError) throw error;
    throw new InvalidFirebaseIdTokenError();
  }
}

function cacheLifetimeSeconds(cacheControl: string | null): number {
  const match = cacheControl?.match(/max-age=(\d+)/i);
  const parsed = match ? Number(match[1]) : 300;

  if (!Number.isFinite(parsed) || parsed < 0) return 300;
  return Math.min(parsed, 6 * 60 * 60);
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function isNumericDate(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value);
}

/**
 * Creates a Firebase ID-token verifier. JWKS state is scoped to this verifier
 * instance so tests and separate Worker instances cannot share stale keys.
 */
export function createFirebaseIdTokenVerifier(
  options: FirebaseIdTokenVerifierOptions = {},
): (token: string, projectId: string) => Promise<AuthenticatedUser> {
  const fetcher =
    options.fetcher ??
    ((input: RequestInfo | URL, init?: RequestInit) => fetch(input, init));
  const nowProvider = options.now ?? Date.now;

  let cachedJwks: CachedJwks | undefined;
  let jwksRequest: Promise<CachedJwks> | undefined;

  async function loadFirebaseJwks(
    forceRefresh = false,
  ): Promise<CachedJwks> {
    if (forceRefresh) {
      // Wait for an in-flight fetch before invalidating the old key set.
      // This avoids accidentally treating a stale in-flight request as the
      // forced refresh when a Firebase signing key has just rotated.
      const pendingRequest = jwksRequest;
      if (pendingRequest) {
        try {
          await pendingRequest;
        } catch {
          // A fresh request below will determine whether Firebase is reachable.
        }

        if (jwksRequest === pendingRequest) {
          jwksRequest = undefined;
        }
      }

      cachedJwks = undefined;
    }

    if (
      !forceRefresh &&
      cachedJwks &&
      cachedJwks.expiresAt > nowProvider()
    ) {
      return cachedJwks;
    }

    if (jwksRequest) return jwksRequest;

    const request = (async () => {
      let response: Response;

      try {
        response = await fetcher(FIREBASE_JWKS_URL, {
          headers: { Accept: "application/json" },
          signal: AbortSignal.timeout(8000),
        });
      } catch {
        throw new FirebaseVerificationUnavailableError();
      }

      if (!response.ok) {
        throw new FirebaseVerificationUnavailableError();
      }

      let document: FirebaseJwks;

      try {
        document = (await response.json()) as FirebaseJwks;
      } catch {
        throw new FirebaseVerificationUnavailableError();
      }

      if (
        !document ||
        !Array.isArray(document.keys) ||
        document.keys.length === 0
      ) {
        throw new FirebaseVerificationUnavailableError();
      }

      const keys = document.keys.filter(
        (key) =>
          key.kty === "RSA" &&
          key.alg === "RS256" &&
          key.use === "sig" &&
          typeof key.kid === "string",
      );

      if (keys.length === 0) {
        throw new FirebaseVerificationUnavailableError();
      }

      const cache = {
        keys,
        expiresAt:
          nowProvider() +
          cacheLifetimeSeconds(response.headers.get("Cache-Control")) * 1000,
      };

      cachedJwks = cache;
      return cache;
    })();

    jwksRequest = request;

    try {
      return await request;
    } finally {
      if (jwksRequest === request) {
        jwksRequest = undefined;
      }
    }
  }

  return async function verifyFirebaseIdToken(
    token: string,
    projectId: string,
  ): Promise<AuthenticatedUser> {
    const normalizedProjectId = projectId.trim();

    if (!normalizedProjectId || token.length > 8192) {
      throw new InvalidFirebaseIdTokenError();
    }

    const segments = token.split(".");
    if (segments.length !== 3) {
      throw new InvalidFirebaseIdTokenError();
    }

    const [encodedHeader, encodedPayload, encodedSignature] = segments;
    const decodedHeader = decodeJsonSegment<unknown>(encodedHeader);
    const decodedPayload = decodeJsonSegment<unknown>(encodedPayload);

    if (!isRecord(decodedHeader) || !isRecord(decodedPayload)) {
      throw new InvalidFirebaseIdTokenError();
    }

    const header = decodedHeader as FirebaseJwtHeader;
    const payload = decodedPayload as FirebaseJwtPayload;
    const signature = decodeBase64Url(encodedSignature);

    if (
      header.alg !== "RS256" ||
      typeof header.kid !== "string" ||
      header.kid.length === 0 ||
      header.kid.length > 256 ||
      (header.typ !== undefined && header.typ !== "JWT") ||
      header.crit !== undefined
    ) {
      throw new InvalidFirebaseIdTokenError();
    }

    const now = Math.floor(nowProvider() / 1000);

    if (
      payload.aud !== normalizedProjectId ||
      payload.iss !==
        "https://securetoken.google.com/" + normalizedProjectId ||
      typeof payload.sub !== "string" ||
      payload.sub.trim().length === 0 ||
      payload.sub.length > 128 ||
      !isNumericDate(payload.exp) ||
      !isNumericDate(payload.iat) ||
      !isNumericDate(payload.auth_time) ||
      payload.exp <= now ||
      payload.iat > now + 300 ||
      payload.auth_time > now + 300 ||
      payload.auth_time > payload.iat + 300 ||
      payload.exp <= payload.iat ||
      payload.exp - payload.iat > 3900
    ) {
      throw new InvalidFirebaseIdTokenError();
    }

    let jwks = await loadFirebaseJwks();
    let jwk = jwks.keys.find((key) => key.kid === header.kid);

    if (!jwk) {
      jwks = await loadFirebaseJwks(true);
      jwk = jwks.keys.find((key) => key.kid === header.kid);
    }

    if (!jwk) {
      throw new InvalidFirebaseIdTokenError();
    }

    let publicKey: CryptoKey;

    try {
      publicKey = await crypto.subtle.importKey(
        "jwk",
        jwk,
        {
          name: "RSASSA-PKCS1-v1_5",
          hash: "SHA-256",
        },
        false,
        ["verify"],
      );
    } catch {
      throw new FirebaseVerificationUnavailableError();
    }

    const signingInput = new TextEncoder().encode(
      encodedHeader + "." + encodedPayload,
    );

    let signatureIsValid: boolean;

    try {
      signatureIsValid = await crypto.subtle.verify(
        "RSASSA-PKCS1-v1_5",
        publicKey,
        signature,
        signingInput,
      );
    } catch {
      throw new InvalidFirebaseIdTokenError();
    }

    if (!signatureIsValid) {
      throw new InvalidFirebaseIdTokenError();
    }

    return {
      uid: payload.sub,
      email: typeof payload.email === "string" ? payload.email : undefined,
      emailVerified: payload.email_verified === true,
    };
  };
}

/** Default production verifier using Google's published Firebase signing keys. */
export const verifyFirebaseIdToken = createFirebaseIdTokenVerifier();
