import '../../domain/entities/payment_transaction.dart';

class PaymentTransactionModel {
  const PaymentTransactionModel({
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

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Invalid payment response field: $key');
      }
      return value;
    }

    final rawAmount = json['amount'];
    if (rawAmount is! num ||
        !rawAmount.isFinite ||
        rawAmount < 0 ||
        rawAmount != rawAmount.roundToDouble()) {
      throw const FormatException('Invalid payment amount.');
    }

    final rawStatus = requiredString('status');
    final status = PaymentStatus.values.where(
      (candidate) => candidate.name == rawStatus,
    );
    if (status.isEmpty) {
      throw const FormatException('Invalid payment status.');
    }

    final createdAt = DateTime.tryParse(requiredString('createdAt'));
    if (createdAt == null) {
      throw const FormatException('Invalid payment creation timestamp.');
    }

    final rawPaidAt = json['paidAt'];
    DateTime? paidAt;
    if (rawPaidAt != null) {
      if (rawPaidAt is! String || (paidAt = DateTime.tryParse(rawPaidAt)) == null) {
        throw const FormatException('Invalid payment completion timestamp.');
      }
    }

    final rawAuthorizationUrl = json['authorizationUrl'];
    if (rawAuthorizationUrl != null && rawAuthorizationUrl is! String) {
      throw const FormatException('Invalid Paystack checkout URL.');
    }

    return PaymentTransactionModel(
      reference: requiredString('reference'),
      packageId: requiredString('packageId'),
      amountKobo: rawAmount.toInt(),
      currency: requiredString('currency'),
      status: status.first,
      authorizationUrl: rawAuthorizationUrl as String?,
      createdAt: createdAt,
      paidAt: paidAt,
    );
  }

  PaymentTransaction toEntity() {
    return PaymentTransaction(
      reference: reference,
      packageId: packageId,
      amountKobo: amountKobo,
      currency: currency,
      status: status,
      authorizationUrl: authorizationUrl,
      createdAt: createdAt,
      paidAt: paidAt,
    );
  }
}
