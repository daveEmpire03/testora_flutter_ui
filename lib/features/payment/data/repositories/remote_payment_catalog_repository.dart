import '../../domain/entities/exam_payment_package.dart';
import '../../domain/repositories/payment_catalog_repository.dart';
import '../testora_payment_api.dart';

/// Fetches exam packages from the live Django backend.
/// Maps backend fields (amount_kobo, code, description) to [ExamPaymentPackage].
class RemotePaymentCatalogRepository implements PaymentCatalogRepository {
  const RemotePaymentCatalogRepository(this._api);

  final TestoraPaymentApi _api;

  @override
  Future<List<ExamPaymentPackage>> getPackages() async {
    final raw = await _api.fetchPackages();
    return raw.map(_fromJson).toList();
  }

  @override
  Future<ExamPaymentPackage?> getPackageById(String id) async {
    final packages = await getPackages();
    for (final p in packages) {
      if (p.id == id) return p;
    }
    return null;
  }

  static ExamPaymentPackage _fromJson(Map<String, dynamic> json) {
    final code = json['code'] as String? ?? '';
    final amountKobo = (json['amount_kobo'] as num?)?.toInt() ?? 0;
    return ExamPaymentPackage(
      id: code,
      name: json['name'] as String? ?? code,
      description: json['description'] as String? ?? '',
      priceNaira: amountKobo ~/ 100,
      iconKey: _iconKeyForCode(code),
    );
  }

  /// Maps the backend package code slug to a local icon key.
  /// Add new mappings here as packages are created in Django admin.
  static String _iconKeyForCode(String code) {
    switch (code) {
      case 'utme':
        return 'school';
      case 'waec':
        return 'menu_book';
      case 'post-utme':
        return 'account_balance';
      case 'postgraduate':
        return 'workspace_premium';
      default:
        return 'quiz';
    }
  }
}
