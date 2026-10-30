import '../entities/payment_transaction.dart';

abstract interface class PaymentRepository {
  Future<PaymentTransaction> initializeCheckout({
    required String packageId,
  });

  Future<PaymentTransaction> getPaymentStatus({
    required String reference,
  });

  Future<PaymentTransaction> verifyPayment({
    required String reference,
  });

  Future<bool> hasActiveEntitlement({
    required String packageId,
  });
}

class PaymentRepositoryException implements Exception {
  const PaymentRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
