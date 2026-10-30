# Testora Cloudflare API

Cloudflare Worker API for Testora. The Flutter application uses Firebase Authentication for identity. This Worker verifies Firebase ID tokens, initializes Paystack hosted checkouts, verifies successful transactions server-side, stores payment records in D1, and grants exam-package entitlements.

## Stack

- Cloudflare Workers + Wrangler
- Hono
- Cloudflare D1
- Firebase Authentication ID-token verification using Google's published RS256 JWKs and Web Crypto
- Paystack hosted checkout and signed webhooks
- Vitest with the Cloudflare Workers test runtime

## API

All application endpoints are under `/api/v1`.

| Method | Endpoint | Authentication | Purpose |
| --- | --- | --- | --- |
| GET | `/health` | Public | Liveness |
| GET | `/health/ready` | Public | D1 readiness |
| GET | `/auth/me` | Firebase | Return verified identity |
| POST | `/payments/initialize` | Firebase | Create Paystack checkout |
| GET | `/payments/:reference/status` | Firebase | Read caller-owned payment status |
| POST | `/payments/:reference/verify` | Firebase | Verify with Paystack and grant access on success |
| GET | `/entitlements` | Firebase | List caller's entitlements |
| GET | `/entitlements/:packageId` | Firebase | Check access to one exam package |
| POST | `/webhooks/paystack` | Paystack signature | Process Paystack events |

### Initialize a checkout

Send only a package identifier:

```http
POST /api/v1/payments/initialize
Authorization: Bearer FIREBASE_ID_TOKEN
Content-Type: application/json

{ "packageId": "utme" }
```

The server obtains the Firebase UID and email from the verified ID token and determines the amount from its own catalogue. The client's amount, UID, package price, and payment status are never trusted.

The server catalogue currently matches the Flutter catalogue:

| Package ID | Amount | Paystack amount |
| --- | ---: | ---: |
| utme | NGN 2,000 | 200000 kobo |
| waec | NGN 4,000 | 400000 kobo |
| post-utme | NGN 3,000 | 300000 kobo |
| postgraduate | NGN 5,000 | 500000 kobo |

The response includes a Paystack `authorizationUrl` and a unique `reference`. The client must launch that URL, then call the authenticated verify endpoint with the returned reference after checkout returns to the app. A browser redirect by itself never grants access.

### Webhooks

Configure the Paystack dashboard webhook URL as:

```text
https://YOUR_WORKER_DOMAIN/api/v1/webhooks/paystack
```

The Worker validates `x-paystack-signature` against the exact raw request body using HMAC-SHA512, then independently calls Paystack's verify endpoint. A D1 batch updates the payment and grants the entitlement atomically. Repeated webhook deliveries are safe to process.

## Local development

Use Node.js and npm, then:

```powershell
cd cloudflare-api
npm install
```

### 1. Create the D1 database

Run:

```powershell
npx wrangler d1 create testora-db
```

Copy the returned database ID into `wrangler.jsonc`, replacing the all-zero local placeholder in `d1_databases[0].database_id`. Do not deploy while the placeholder remains.

Apply the schema locally:

```powershell
npx wrangler d1 migrations apply testora-db --local
npx wrangler types
```

### 2. Configure secrets

Copy the example file:

```powershell
Copy-Item .dev.vars.example .dev.vars
```

Edit `.dev.vars` and replace the placeholder with your Paystack **test** secret key. Never commit `.dev.vars`.

`FIREBASE_PROJECT_ID` is configured in `wrangler.jsonc` as `testora-pays`, sourced from this repository's FlutterFire configuration. Update it if the Firebase project changes.

`PAYSTACK_CALLBACK_URL` is optional. Configure it only after the Testora web/mobile return route is decided. It must be an HTTPS URL.

### 3. Run migrations, tests, and Worker

```powershell
npm run db:migrate:local
npm run typecheck
npm run test:run
npm run dev
```

Local Worker URL is normally `http://localhost:8787`.

The example CORS origins in `wrangler.jsonc` allow Flutter Web on port 7357. Run Flutter Web with that port during local integration, or update `ALLOWED_ORIGINS` to the exact origin being used.

## Production setup

1. Create the production D1 database and replace the D1 database ID in `wrangler.jsonc`.
2. Apply migrations remotely with `npm run db:migrate:remote`.
3. Set a production Paystack secret using `npx wrangler secret put PAYSTACK_SECRET_KEY`. Do not use a test secret in production.
4. Configure the exact production Flutter Web origin in `ALLOWED_ORIGINS`.
5. Deploy with `npm run deploy`.
6. Add the deployed webhook URL to Paystack Dashboard.
7. Run a controlled test payment before enabling paid access for users.

## Security notes

- Firebase UID comes only from a verified Firebase ID token.
- The backend owns the package prices; client-supplied amounts and UIDs are rejected.
- Paystack secret keys are Worker secrets, never Flutter configuration.
- Payment completion requires matching reference, amount, currency, and (when returned) customer email.
- Entitlement creation is part of the same D1 batch as payment completion.
- The webhook signature is checked against the raw request bytes.
- Transaction status is scoped to the authenticated Firebase UID.
- Firebase ID-token signature, issuer, audience, expiry, issued-at, authentication-time, and subject are checked. This implementation does not perform Firebase Admin SDK revocation/disabled-user checks; add that only if the product requires immediate revocation enforcement.

## Scope boundaries

Manual bank transfer remains a UI-only option and is not implemented by this API. Refund, dispute, and chargeback entitlement revocation are not yet implemented. The Worker does not grant an entitlement merely because a user returns from Paystack.
