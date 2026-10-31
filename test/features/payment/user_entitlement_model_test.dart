import 'package:flutter_test/flutter_test.dart';
import 'package:testora_flutter_ui/features/payment/data/models/user_entitlement_model.dart';
import 'package:testora_flutter_ui/features/payment/domain/entities/user_entitlement.dart';

void main() {
  group('UserEntitlementModel', () {
    test('maps an active entitlement', () {
      final model = UserEntitlementModel.fromJson({
        'packageId': 'postgraduate',
        'paymentReference': 'testora_0123456789abcdef0123456789abcdef',
        'status': 'active',
        'grantedAt': '2026-10-31T10:00:00.000Z',
      });

      final entitlement = model.toEntity();

      expect(entitlement.packageId, 'postgraduate');
      expect(entitlement.paymentReference, startsWith('testora_'));
      expect(entitlement.status, UserEntitlementStatus.active);
      expect(entitlement.isActive, isTrue);
      expect(entitlement.grantedAt.toUtc(), DateTime.utc(2026, 10, 31, 10));
    });

    test('maps revoked access without treating it as active', () {
      final model = UserEntitlementModel.fromJson({
        'packageId': 'waec',
        'paymentReference': 'testora_0123456789abcdef0123456789abcdef',
        'status': 'revoked',
        'grantedAt': '2026-10-31T10:00:00.000Z',
      });

      expect(model.toEntity().isActive, isFalse);
    });

    test('rejects unknown entitlement statuses', () {
      expect(
        () => UserEntitlementModel.fromJson({
          'packageId': 'waec',
          'paymentReference': 'testora_0123456789abcdef0123456789abcdef',
          'status': 'expired',
          'grantedAt': '2026-10-31T10:00:00.000Z',
        }),
        throwsFormatException,
      );
    });
  });
}
