import 'package:flutter_test/flutter_test.dart';
import 'package:testora_flutter_ui/features/payment/data/models/payment_transaction_model.dart';
import 'package:testora_flutter_ui/features/payment/domain/entities/payment_transaction.dart';

void main() {
  group('PaymentTransactionModel', () {
    const createdAt = '2026-10-30T22:45:20.000Z';

    test('maps the Cloudflare initialize response into a domain transaction', () {
      final model = PaymentTransactionModel.fromJson({
        'reference': 'testora_0123456789abcdef0123456789abcdef',
        'packageId': 'utme',
        'amount': 200000,
        'currency': 'NGN',
        'status': 'pending',
        'authorizationUrl': 'https://checkout.paystack.com/example',
        'createdAt': createdAt,
        'paidAt': null,
      });

      final transaction = model.toEntity();

      expect(transaction.reference, 'testora_0123456789abcdef0123456789abcdef');
      expect(transaction.packageId, 'utme');
      expect(transaction.amountKobo, 200000);
      expect(transaction.currency, 'NGN');
      expect(transaction.status, PaymentStatus.pending);
      expect(
        transaction.authorizationUrl,
        'https://checkout.paystack.com/example',
      );
      expect(transaction.createdAt, DateTime.parse(createdAt));
      expect(transaction.paidAt, isNull);
    });

    test('parses a successful payment with its paid timestamp', () {
      final model = PaymentTransactionModel.fromJson({
        'reference': 'testora_0123456789abcdef0123456789abcdef',
        'packageId': 'waec',
        'amount': 400000,
        'currency': 'NGN',
        'status': 'success',
        'authorizationUrl': null,
        'createdAt': createdAt,
        'paidAt': '2026-10-30T22:50:00.000Z',
      });

      expect(model.status, PaymentStatus.success);
      expect(model.paidAt, DateTime.parse('2026-10-30T22:50:00.000Z'));
    });

    test('rejects an unknown backend payment status', () {
      expect(
        () => PaymentTransactionModel.fromJson({
          'reference': 'testora_reference',
          'packageId': 'utme',
          'amount': 200000,
          'currency': 'NGN',
          'status': 'authorized',
          'createdAt': createdAt,
        }),
        throwsFormatException,
      );
    });

    test('rejects non-integer or malformed kobo amounts', () {
      expect(
        () => PaymentTransactionModel.fromJson({
          'reference': 'testora_reference',
          'packageId': 'utme',
          'amount': 2000.5,
          'currency': 'NGN',
          'status': 'pending',
          'createdAt': createdAt,
        }),
        throwsFormatException,
      );
    });
  });
}
