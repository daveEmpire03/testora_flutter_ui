import 'package:flutter_test/flutter_test.dart';
import 'package:testora_flutter_ui/features/payment/data/repositories/local_payment_catalog_repository.dart';

void main() {
  group('LocalPaymentCatalogRepository', () {
    const repository = LocalPaymentCatalogRepository();

    test('exposes the configured exam prices', () {
      final packages = repository.getPackages();
      final byId = {for (final item in packages) item.id: item};

      expect(byId['utme']?.priceNaira, 2000);
      expect(byId['waec']?.priceNaira, 4000);
      expect(byId['post-utme']?.priceNaira, 3000);
      expect(byId['postgraduate']?.priceNaira, 5000);
    });

    test('converts naira pricing to kobo for gateways', () {
      final utme = repository.getPackageById('utme');

      expect(utme, isNotNull);
      expect(utme!.priceKobo, 200000);
    });

    test('returns null for an unknown package', () {
      expect(repository.getPackageById('unknown'), isNull);
    });
  });
}
