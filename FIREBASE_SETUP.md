# Firebase Authentication setup for Testora

Testora uses Firebase Authentication for user identity and Cloudflare Workers for protected application and payment APIs.

## Firebase project

The repository's FlutterFire configuration currently targets project ID `testora-pays`. The generated Flutter options are in `lib/firebase_options.dart`, with web platform metadata in `firebase.json`.

In Firebase Console:

1. Select project `testora-pays`.
2. Open **Authentication → Sign-in method**.
3. Enable **Email/Password**.
4. Confirm the web app registered in Firebase matches the checked-in FlutterFire configuration.

If the Firebase project or app registration changes, regenerate options from the repository root:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure --platforms=web
```

## Flutter authentication

The Flutter app uses Firebase Auth for email/password registration, login, session restoration, password reset and logout. The signed-in Firebase user is the source of the ID token sent to the Cloudflare API.

The user's ID token must be sent in the HTTP Authorization header:

```text
Authorization: Bearer FIREBASE_ID_TOKEN
```

Never send a UID in the request body as proof of identity. The Worker verifies the token's signature and claims and derives the UID from its verified subject claim.

## Cloudflare configuration

The Worker is in `cloudflare-api`. Its `wrangler.jsonc` currently sets:

```text
FIREBASE_PROJECT_ID = testora-pays
```

The Worker uses the Firebase project's published RS256 signing keys to verify tokens. It does not need a Firebase service-account private key.

Follow [cloudflare-api/README.md](./cloudflare-api/README.md) to create the D1 database, apply migrations, configure Paystack secrets, run tests and deploy.

## Registration profile fields

Firebase Email/Password Auth does not verify or persist the phone number entered on the Testora registration form as a Firebase phone number. Do not treat an unverified phone field as verified identity. Profile persistence can be added through an authenticated Cloudflare profile endpoint.

## Security

- Firebase client configuration contains public app identifiers; it is not a Paystack secret.
- Never put Paystack secret keys in Flutter, `firebase_options.dart`, or Git.
- The Worker must derive user identity from its verified Firebase ID token.
- The Worker does not yet check Firebase token revocation or disabled-account state through the Firebase Admin SDK.
