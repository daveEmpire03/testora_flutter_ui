from django.urls import path
from .views import packages,InitializePaymentView,VerifyPaymentView,PaystackWebhookView,payment_status,entitlements
urlpatterns=[path('packages/',packages),path('payments/initialize/',InitializePaymentView.as_view()),path('payments/verify/',VerifyPaymentView.as_view()),path('payments/webhook/',PaystackWebhookView.as_view()),path('payments/<str:reference>/',payment_status),path('entitlements/',entitlements)]
