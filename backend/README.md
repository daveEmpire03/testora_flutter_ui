## Testora payment backend

Django REST API for Paystack hosted checkout. Secret keys stay server-side; Flutter receives a hosted authorization URL. Exam entitlement is granted only after server-to-server verification confirms successful status, exact amount, currency and reference. Signed `charge.success` webhooks are independently re-verified and entitlement creation is idempotent.

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
Create packages in Django admin with amounts in kobo: UTME 200000, WAEC 400000, Post-UTME 300000, Postgraduate 500000 (confirm prices before enabling). Configure the Paystack webhook URL as `https://YOUR_API_HOST/api/payments/webhook/`.

### API
- `GET /api/health/`, `GET /api/packages/`
- `POST /api/payments/initialize/` JSON `{email, package_code}`
- `POST /api/payments/verify/` JSON `{reference}`
- `GET /api/payments/<reference>/`
- `GET /api/entitlements/?email=...` (not an access-control mechanism)
- `POST /api/payments/webhook/` (Paystack-signed only)

### Flutter integration
`lib/features/payment/data/testora_payment_api.dart` calls the API and `testora_paystack_checkout.dart` opens the hosted checkout URL in the system browser. Configure the API URL at build time with `--dart-define=TESTORA_API_BASE_URL=https://YOUR_API_HOST/api`. After the user returns from the browser, call `verifyPendingPayment(pending)` and show paid status only when the API response has `status == 'success'`. Do not grant exam access based on browser return alone.

### Before public launch
The current frontend repository README describes this project as a UI starter with no backend/auth persistence. This integration adds a payment API client and checkout coordinator, but the existing payment screen still needs to call this coordinator from its Pay button and handle app resume/callback. The service currently associates purchases by email; email-only entitlement lookup is NOT authorization. Bind purchases to authenticated Testora user IDs and enforce entitlement checks server-side before allowing paid exam content. Configure HTTPS, `DEBUG=false`, production hosts/CORS, PostgreSQL, backups, monitoring and valid Paystack keys. Do not treat frontend/callback data as proof of payment. No payment is faked.

### Tests
`python manage.py test`
