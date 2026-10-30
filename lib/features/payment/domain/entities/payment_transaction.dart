enum PaymentStatus {
  initializing,
  pending,
  success,
  failed,
}

class PaymentTransaction {
  const PaymentTransaction({
    required this.reference,
    required this.packageId,
    required this.amountKobo,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.authorizationUrl,
    this.paidAt,
  });

  final String reference;
  final String packageId;
  final int amountKobo;
  final String currency;
  final PaymentStatus status;
  final String? authorizationUrl;
  final DateTime createdAt;
  final DateTime? paidAt;

  bool get isSuccessful => status == PaymentStatus.success;
}
