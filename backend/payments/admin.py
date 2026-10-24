from django.contrib import admin
from .models import ExamPackage,Payment,ExamEntitlement
@admin.register(ExamPackage)
class ExamPackageAdmin(admin.ModelAdmin): list_display=('code','name','amount_kobo','currency','active'); list_filter=('active','currency'); search_fields=('code','name')
@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin): list_display=('reference','email','package','amount_kobo','currency','status','created_at','paid_at'); list_filter=('status','currency'); search_fields=('reference','email','paystack_reference'); readonly_fields=('reference','created_at','updated_at','paid_at','gateway_payload')
@admin.register(ExamEntitlement)
class ExamEntitlementAdmin(admin.ModelAdmin): list_display=('email','package','payment','granted_at'); search_fields=('email','package__name'); readonly_fields=('email','package','payment','granted_at')
