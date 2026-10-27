import '../../domain/entities/exam_payment_package.dart';
import '../../domain/repositories/payment_catalog_repository.dart';

/// Offline/dev fallback catalog — used when the remote API is unavailable.
class LocalPaymentCatalogRepository implements PaymentCatalogRepository {
  const LocalPaymentCatalogRepository();

  static const _packages = <ExamPaymentPackage>[
    ExamPaymentPackage(
      id: 'utme',
      name: 'UTME',
      description: 'Unlock Testora UTME preparation and practice access.',
      priceNaira: 2000,
      iconKey: 'school',
    ),
    ExamPaymentPackage(
      id: 'waec',
      name: 'WAEC',
      description: 'Unlock WAEC preparation across supported subjects.',
      priceNaira: 4000,
      iconKey: 'menu_book',
    ),
    ExamPaymentPackage(
      id: 'post-utme',
      name: 'Post-UTME',
      description: 'Prepare for university screening and Post-UTME practice.',
      priceNaira: 3000,
      iconKey: 'account_balance',
    ),
    ExamPaymentPackage(
      id: 'postgraduate',
      name: 'Postgraduate',
      description: 'Unlock postgraduate entrance and aptitude preparation.',
      priceNaira: 5000,
      iconKey: 'workspace_premium',
    ),
  ];

  @override
  Future<List<ExamPaymentPackage>> getPackages() async => _packages;

  @override
  Future<ExamPaymentPackage?> getPackageById(String id) async {
    for (final package in _packages) {
      if (package.id == id) return package;
    }
    return null;
  }
}
