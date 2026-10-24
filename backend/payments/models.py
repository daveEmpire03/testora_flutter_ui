import uuid
from django.db import models
from django.utils import timezone
class ExamPackage(models.Model):
 code=models.SlugField(unique=True); name=models.CharField(max_length=120); amount_kobo=models.PositiveIntegerField(); currency=models.CharField(max_length=3,default='NGN'); active=models.BooleanField(default=True); description=models.CharField(max_length=255,blank=True); created_at=models.DateTimeField(auto_now_add=True)
 def __str__(self): return self.name
class Payment(models.Model):
 class Status(models.TextChoices): PENDING='pending','Pending'; SUCCESS='success','Success'; FAILED='failed','Failed'
 reference=models.UUIDField(default=uuid.uuid4,unique=True,editable=False); package=models.ForeignKey(ExamPackage,on_delete=models.PROTECT,related_name='payments'); email=models.EmailField(db_index=True); amount_kobo=models.PositiveIntegerField(); currency=models.CharField(max_length=3,default='NGN'); status=models.CharField(max_length=16,choices=Status.choices,default='pending',db_index=True); paystack_reference=models.CharField(max_length=100,unique=True,null=True,blank=True); authorization_url=models.URLField(max_length=1000,blank=True); access_code=models.CharField(max_length=255,blank=True); gateway_payload=models.JSONField(default=dict,blank=True); paid_at=models.DateTimeField(null=True,blank=True); created_at=models.DateTimeField(auto_now_add=True); updated_at=models.DateTimeField(auto_now=True)
 def mark_paid(self):
  if self.status != self.Status.SUCCESS:
   self.status=self.Status.SUCCESS; self.paid_at=timezone.now(); self.save(update_fields=['status','paid_at','gateway_payload','updated_at'])
class ExamEntitlement(models.Model):
 email=models.EmailField(db_index=True); package=models.ForeignKey(ExamPackage,on_delete=models.PROTECT); payment=models.OneToOneField(Payment,on_delete=models.PROTECT,related_name='entitlement'); granted_at=models.DateTimeField(auto_now_add=True)
 class Meta: constraints=[models.UniqueConstraint(fields=['email','package'],name='unique_email_exam_package')]
