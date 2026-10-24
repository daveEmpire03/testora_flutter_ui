import hashlib,hmac,requests
from django.conf import settings
BASE='https://api.paystack.co'
class PaystackError(Exception): pass
def headers():
 if not settings.PAYSTACK_SECRET_KEY: raise PaystackError('PAYSTACK_SECRET_KEY is not configured.')
 return {'Authorization':'Bearer '+settings.PAYSTACK_SECRET_KEY,'Content-Type':'application/json'}
def initialize_payment(payment):
 payload={'email':payment.email,'amount':payment.amount_kobo,'currency':payment.currency,'reference':str(payment.reference),'callback_url':settings.PAYSTACK_CALLBACK_URL,'metadata':{'payment_reference':str(payment.reference),'package_code':payment.package.code}}
 try:
  r=requests.post(BASE+'/transaction/initialize',json=payload,headers=headers(),timeout=(3.05,15)); r.raise_for_status(); body=r.json()
 except (requests.RequestException,ValueError) as e: raise PaystackError('Unable to initialize Paystack transaction.') from e
 if not body.get('status') or not body.get('data',{}).get('authorization_url'): raise PaystackError('Paystack rejected transaction initialization.')
 return body['data']
def verify_transaction(reference):
 try:
  r=requests.get(BASE+'/transaction/verify/'+reference,headers=headers(),timeout=(3.05,15)); r.raise_for_status(); body=r.json()
 except (requests.RequestException,ValueError) as e: raise PaystackError('Unable to verify Paystack transaction.') from e
 if not body.get('status') or not isinstance(body.get('data'),dict): raise PaystackError('Paystack verification failed.')
 return body['data']
def valid_webhook_signature(raw,signature):
 if not settings.PAYSTACK_SECRET_KEY or not signature:return False
 expected=hmac.new(settings.PAYSTACK_SECRET_KEY.encode(),raw,hashlib.sha512).hexdigest()
 return hmac.compare_digest(expected,signature)
