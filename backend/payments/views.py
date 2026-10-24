import json
from django.db import transaction as db_transaction
from django.db.models import Q
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.throttling import AnonRateThrottle
from .models import ExamPackage,Payment,ExamEntitlement
from .services import PaystackError,initialize_payment,verify_transaction,valid_webhook_signature
class PaymentThrottle(AnonRateThrottle): scope='payments'
def health(request): return JsonResponse({'status':'ok'})
@api_view(['GET'])
def packages(request): return Response({'results':[{'code':p.code,'name':p.name,'amount_kobo':p.amount_kobo,'currency':p.currency,'description':p.description} for p in ExamPackage.objects.filter(active=True).order_by('amount_kobo')]})
class InitializePaymentView(APIView):
 throttle_classes=[PaymentThrottle]
 def post(self,request):
  email=str(request.data.get('email','')).strip().lower(); code=str(request.data.get('package_code','')).strip()
  if len(email)>254 or '@' not in email or '.' not in email.rsplit('@',1)[-1]: return Response({'detail':'A valid email address is required.'},status=400)
  try: package=ExamPackage.objects.get(code=code,active=True)
  except ExamPackage.DoesNotExist: return Response({'detail':'Unknown or unavailable exam package.'},status=400)
  payment=Payment.objects.create(package=package,email=email,amount_kobo=package.amount_kobo,currency=package.currency)
  try: data=initialize_payment(payment)
  except PaystackError as exc:
   payment.status=Payment.Status.FAILED; payment.save(update_fields=['status','updated_at']); return Response({'detail':str(exc)},status=503)
  payment.paystack_reference=str(data.get('reference') or payment.reference); payment.authorization_url=data['authorization_url']; payment.access_code=data.get('access_code',''); payment.gateway_payload={'status':'initialized'}
  payment.save(update_fields=['paystack_reference','authorization_url','access_code','gateway_payload','updated_at'])
  return Response({'reference':str(payment.reference),'authorization_url':payment.authorization_url,'access_code':payment.access_code,'amount_kobo':payment.amount_kobo,'currency':payment.currency},status=201)
def apply_verified(payment,data):
 if data.get('status')!='success': return False
 try: amount=int(data.get('amount',-1))
 except (TypeError,ValueError): return False
 if amount!=payment.amount_kobo or str(data.get('currency','')).upper()!=payment.currency or str(data.get('reference',''))!=str(payment.paystack_reference or payment.reference): return False
 with db_transaction.atomic():
  p=Payment.objects.select_for_update().select_related('package').get(pk=payment.pk)
  if p.status==Payment.Status.SUCCESS: return True
  p.gateway_payload={'channel':data.get('channel'),'paid_at':data.get('paid_at'),'gateway_status':data.get('status')}; p.mark_paid()
  ExamEntitlement.objects.get_or_create(email=p.email,package=p.package,defaults={'payment':p})
 return True
class VerifyPaymentView(APIView):
 throttle_classes=[PaymentThrottle]
 def post(self,request):
  ref=str(request.data.get('reference','')).strip()
  if not ref or len(ref)>100:return Response({'detail':'A valid payment reference is required.'},status=400)
  try:p=Payment.objects.select_related('package').get(reference=ref)
  except (Payment.DoesNotExist,ValueError):return Response({'detail':'Payment reference not found.'},status=404)
  try:data=verify_transaction(str(p.paystack_reference or p.reference))
  except PaystackError as exc:return Response({'detail':str(exc)},status=503)
  if not apply_verified(p,data):return Response({'status':'pending','detail':'Payment has not been confirmed as successful.'},status=202)
  return Response({'status':'success','reference':str(p.reference),'package_code':p.package.code,'entitlement_granted':True})
@method_decorator(csrf_exempt,name='dispatch')
class PaystackWebhookView(APIView):
 authentication_classes=[]; permission_classes=[]; throttle_classes=[]
 def post(self,request):
  if not valid_webhook_signature(request.body,request.headers.get('x-paystack-signature','')):return Response({'detail':'Invalid signature.'},status=401)
  try:event=json.loads(request.body)
  except (ValueError,TypeError):return Response({'detail':'Invalid JSON.'},status=400)
  if event.get('event')!='charge.success':return Response({'received':True})
  ref=str((event.get('data') or {}).get('reference',''))
  try:p=Payment.objects.select_related('package').get(Q(reference=ref)|Q(paystack_reference=ref))
  except Payment.DoesNotExist:return Response({'received':True})
  try:data=verify_transaction(str(p.paystack_reference or p.reference))
  except PaystackError:return Response({'detail':'Verification temporarily unavailable.'},status=503)
  if not apply_verified(p,data):return Response({'detail':'Verification mismatch.'},status=400)
  return Response({'received':True})
@api_view(['GET'])
def payment_status(request,reference):
 try:p=Payment.objects.select_related('package').get(reference=reference)
 except (Payment.DoesNotExist,ValueError):return Response({'detail':'Payment not found.'},status=404)
 return Response({'reference':str(p.reference),'status':p.status,'package_code':p.package.code,'entitlement_granted':p.status==Payment.Status.SUCCESS})
@api_view(['GET'])
def entitlements(request):
 email=str(request.query_params.get('email','')).strip().lower()
 if not email or '@' not in email:return Response({'detail':'A valid email query parameter is required.'},status=400)
 rows=ExamEntitlement.objects.filter(email=email).select_related('package').order_by('-granted_at')
 return Response({'results':[{'package_code':r.package.code,'package_name':r.package.name,'granted_at':r.granted_at} for r in rows]})
