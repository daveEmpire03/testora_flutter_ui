from django.db import migrations

def seed_packages(apps, schema_editor):
    Package = apps.get_model('payments', 'ExamPackage')
    packages = [
        ('utme', 'UTME', 200000, 'Unlock Testora UTME preparation and practice access.'),
        ('waec', 'WAEC', 400000, 'Unlock WAEC preparation across supported subjects.'),
        ('post-utme', 'Post-UTME', 300000, 'Prepare for university screening and Post-UTME practice.'),
        ('postgraduate', 'Postgraduate', 500000, 'Unlock postgraduate entrance and aptitude preparation.'),
    ]
    for code, name, amount, description in packages:
        Package.objects.update_or_create(code=code, defaults={'name': name, 'amount_kobo': amount, 'currency': 'NGN', 'active': True, 'description': description})

def unseed_packages(apps, schema_editor):
    Package = apps.get_model('payments', 'ExamPackage')
    Package.objects.filter(code__in=['utme', 'waec', 'post-utme', 'postgraduate']).delete()

class Migration(migrations.Migration):
    dependencies = [('payments', '0001_initial')]
    operations = [migrations.RunPython(seed_packages, unseed_packages)]
