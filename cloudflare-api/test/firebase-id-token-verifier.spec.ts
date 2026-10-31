import { describe, expect, it } from "vitest";

import {
  createFirebaseIdTokenVerifier,
} from "../src/infrastructure/firebase/firebase-id-token-verifier";
import { InvalidFirebaseIdTokenError } from "../src/modules/auth/auth.types";

const projectId = "testora-auth-test";
const encoder = new TextEncoder();

function base64UrlEncode(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }

  return btoa(binary)
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

function encodeJsonSegment(value: Record<string, unknown>): string {
  return base64UrlEncode(encoder.encode(JSON.stringify(value)));
}

async function createRsaKeyPair(): Promise<CryptoKeyPair> {
  return crypto.subtle.generateKey(
    {
      name: "RSASSA-PKCS1-v1_5",
      modulusLength: 2048,
      publicExponent: new Uint8Array([1, 0, 1]),
      hash: "SHA-256",
    },
    true,
    ["sign", "verify"],
  );
}

async function createSignedToken(
  privateKey: CryptoKey,
  kid: string,
  nowMilliseconds: number,
  payloadOverrides: Record<string, unknown> = {},
): Promise<string> {
  const nowSeconds = Math.floor(nowMilliseconds / 1000);
  const header = encodeJsonSegment({
    alg: "RS256",
    typ: "JWT",
    kid,
  });
  const payload = encodeJsonSegment({
    aud: projectId,
    iss: `https://securetoken.google.com/${projectId}`,
    sub: "firebase-test-user-001",
    iat: nowSeconds,
    exp: nowSeconds + 3600,
    auth_time: nowSeconds,
    email: "student@example.com",
    email_verified: true,
    ...payloadOverrides,
  });
  const signingInput = `${header}.${payload}`;
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateKey,
    encoder.encode(signingInput),
  );

  return `${signingInput}.${base64UrlEncode(new Uint8Array(signature))}`;
}

function createJwksFetcher(
  getKeys: (callNumber: number) => JsonWebKey[],
): { fetcher: typeof fetch; calls: () => number } {
  let callCount = 0;

  const fetcher = (async () => {
    callCount += 1;
    return new Response(
      JSON.stringify({ keys: getKeys(callCount) }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Cache-Control": "public, max-age=3600",
        },
      },
    );
  }) as typeof fetch;

  return {
    fetcher,
    calls: () => callCount,
  };
}

describe("Firebase ID-token cryptographic verification", () => {
  it("accepts a correctly signed token for the configured Firebase project", async () => {
    const now = Date.now();
    const keyPair = await createRsaKeyPair();
    const exportedJwk = await crypto.subtle.exportKey(
      "jwk",
      keyPair.publicKey,
    );
    const signingKey = {
      ...exportedJwk,
      kid: "test-signing-key",
      alg: "RS256",
      use: "sig",
    };
    const jwks = createJwksFetcher(() => [signingKey]);
    const verifier = createFirebaseIdTokenVerifier({
      fetcher: jwks.fetcher,
      now: () => now,
    });
    const token = await createSignedToken(
      keyPair.privateKey,
      "test-signing-key",
      now,
    );

    await expect(verifier(token, projectId)).resolves.toEqual({
      uid: "firebase-test-user-001",
      email: "student@example.com",
      emailVerified: true,
    });
    expect(jwks.calls()).toBe(1);
  });

  it("rejects a token with an altered signature", async () => {
    const now = Date.now();
    const keyPair = await createRsaKeyPair();
    const exportedJwk = await crypto.subtle.exportKey(
      "jwk",
      keyPair.publicKey,
    );
    const signingKey = {
      ...exportedJwk,
      kid: "test-signing-key",
      alg: "RS256",
      use: "sig",
    };
    const jwks = createJwksFetcher(() => [signingKey]);
    const verifier = createFirebaseIdTokenVerifier({
      fetcher: jwks.fetcher,
      now: () => now,
    });
    const validToken = await createSignedToken(
      keyPair.privateKey,
      "test-signing-key",
      now,
    );
    const [header, payload, signature] = validToken.split(".");
    const alteredSignature =
      (signature[0] === "A" ? "B" : "A") + signature.slice(1);

    await expect(
      verifier(`${header}.${payload}.${alteredSignature}`, projectId),
    ).rejects.toBeInstanceOf(InvalidFirebaseIdTokenError);
  });

  it("rejects an ID token issued for a different Firebase project before fetching keys", async () => {
    const now = Date.now();
    const jwks = createJwksFetcher(() => []);
    const verifier = createFirebaseIdTokenVerifier({
      fetcher: jwks.fetcher,
      now: () => now,
    });
    const keyPair = await createRsaKeyPair();
    const token = await createSignedToken(
      keyPair.privateKey,
      "test-signing-key",
      now,
      {
        aud: "another-firebase-project",
        iss: "https://securetoken.google.com/another-firebase-project",
      },
    );

    await expect(
      verifier(token, projectId),
    ).rejects.toBeInstanceOf(InvalidFirebaseIdTokenError);
    expect(jwks.calls()).toBe(0);
  });

  it("refreshes Firebase signing keys when a token uses a newly rotated key id", async () => {
    const now = Date.now();
    const keyPair = await createRsaKeyPair();
    const exportedJwk = await crypto.subtle.exportKey(
      "jwk",
      keyPair.publicKey,
    );
    const oldSigningKey = {
      ...exportedJwk,
      kid: "old-signing-key",
      alg: "RS256",
      use: "sig",
    };
    const newSigningKey = {
      ...exportedJwk,
      kid: "new-signing-key",
      alg: "RS256",
      use: "sig",
    };
    const jwks = createJwksFetcher((callNumber) =>
      callNumber === 1 ? [oldSigningKey] : [newSigningKey],
    );
    const verifier = createFirebaseIdTokenVerifier({
      fetcher: jwks.fetcher,
      now: () => now,
    });
    const token = await createSignedToken(
      keyPair.privateKey,
      "new-signing-key",
      now,
    );

    await expect(verifier(token, projectId)).resolves.toMatchObject({
      uid: "firebase-test-user-001",
    });
    expect(jwks.calls()).toBe(2);
  });
});
