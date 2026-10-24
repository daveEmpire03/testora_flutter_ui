import hashlib,hmac
from unittest.mock import patch
from django.test import TestCase,override_settings
from rest_framework.test import APIClient
from .models import ExamPackage,Payment,ExamEntitlement
from .services import valid_webhook_signature
class PaymentFlowTests(TestCase):
 def setUp(self):
  self.client=APIClient(); self.package=ExamPackage.objects.create(code='utme',name='UTME',amount_kobo=200000)
 def test_catalog_returns_server_owned_price(self):
  r=self.client.get('/api/packages/'); self.assertEqual(r.status_code,200); self.assertEqual(r.data['results'][0]['amount_kobo'],200000)
 @patch('payments.views.initialize_payment')
 def test_initialization_uses_server_price(self,initialize):
  initialize.return_value={'reference':'gateway-ref','authorization_url':'https://checkout.paystack.com/test','access_code':'abc'}
  r=self.client.post('/api/payments/initialize/',{'email':'student@example.com','package_code':'utme'},format='json')
  self.assertEqual(r.status_code,201); p=Payment.objects.get(reference=r.data['reference']); self.assertEqual(p.amount_kobo,200000); self.assertEqual(p.paystack_reference,'gateway-ref')
 @patch('payments.views.verify_transaction')
 def test_success_verification_grants_entitlement(self,verify):
  p=Payment.objects.create(package=self.package,email='student@example.com',amount_kobo=200000,paystack_reference='gateway-ref')
  verify.return_value={'status':'success','amount':200000,'currency':'NGN','reference':'gateway-ref','paid_at':'2026-01-01T00:00:00Z','channel':'card'}
  r=self.client.post('/api/payments/verify/',{'reference':str(p.reference)},format='json')
  self.assertEqual(r.status_code,200); self.assertEqual(Payment.objects.get(pk=p.pk).status,Payment.Status.SUCCESS); self.assertEqual(ExamEntitlement.objects.filter(payment=p).count(),1)
 @patch('payments.views.verify_transaction')
 def test_failed_payment_never_grants_entitlement(self,verify):
  p=Payment.objects.create(package=self.package,email='student@example.com',amount_kobo=200000,paystack_reference='gateway-ref')
  verify.return_value={'status':'failed','amount':200000,'currency':'NGN','reference':'gateway-ref'}
  r=self.client.post('/api/payments/verify/',{'reference':str(p.reference)},format='json')
  self.assertEqual(r.status_code,202); self.assertEqual(ExamEntitlement.objects.count(),0)
 @override_settings(PAYSTACK_SECRET_KEY='test-secret')
 def test_webhook_signature_is_constant_time_checked(self):
  body=b'{"event":"charge.success"}'; signature=hmac.new(b'test-secret',body,hashlib.sha512).hexdigest()
  self.assertTrue(valid_webhook_signature(body,signature)); self.assertFalse(valid_webhook_signature(body,'bad'))
