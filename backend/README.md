## Testora payment backend

Django REST API for Paystack hosted checkout. Secret keys stay server-side; the app receives a hosted authorization URL. Exam access is granted only after server-to-server verification confirms `success`, exact amount, currency and reference. Signed `charge.success` webhooks are also independently re-verified and entitlement creation is idempotent.

### Local setup (PowerShell)
```powershell
cd backend
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
$env:DJANGO_SECRET_KEY = 'replace-with-long-random-value'
$env:DJANGO_DEBUG = 'true'
$env:PAYSTACK_SECRET_KEY = 'sk_test_your_valid_test_key'
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```
Create packages in Django admin with prices in kobo: UTME 200000, WAEC 400000, Post-UTME 300000, Postgraduate 500000 (confirm prices before enabling). Configure Paystack webhook URL as `https://YOUR_API_HOST/api/payments/webhook/`.

### Endpoints
`GET /api/health/`, `GET /api/packages/`, `POST /api/payments/initialize/` with `{email, package_code}`, `POST /api/payments/verify/` with `{reference}`, `GET /api/payments/<reference>/`, `GET /api/entitlements/?email=...`, and Paystack-only `POST /api/payments/webhook/`.

### Before public launch
The repository README identifies the app as a UI starter without backend/auth persistence. This initial service therefore uses email to associate purchases; email-only entitlement lookup is NOT authorization and must not gate paid exam content. Bind purchases to authenticated Testora user IDs and enforce entitlement checks server-side before public release. Use HTTPS, `DEBUG=false`, production hosts/CORS, PostgreSQL, backups, monitoring and a valid Paystack key. Never treat the callback or frontend as proof of payment. No test payment is treated as real.
