# Testora

Testora is a Flutter exam-preparation application using Firebase Authentication for sign-in and a Cloudflare Worker API for payment processing and exam-package entitlements.

## Application

- Flutter + Riverpod
- GoRouter navigation
- Firebase Authentication (email/password)
- Exam preparation and practice catalogues
- Paystack hosted checkout integration is being implemented through the Cloudflare API

## Backend

The backend lives in [cloudflare-api](./cloudflare-api/README.md).

It uses Cloudflare Workers, Hono and D1. Firebase ID tokens are verified by the Worker. Paystack transactions are initialized and verified server-side; successful payment records and exam entitlements are stored in D1.

See [Cloudflare API setup](./cloudflare-api/README.md) for local development, D1 provisioning, secrets and deployment instructions.

## Flutter setup

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

See [Firebase setup](./FIREBASE_SETUP.md) for Firebase project configuration.
