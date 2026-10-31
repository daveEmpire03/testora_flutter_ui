import '../../domain/entities/user_entitlement.dart';

class UserEntitlementModel {
  const UserEntitlementModel({
    required this.packageId,
    required this.paymentReference,
    required this.status,
    required this.grantedAt,
  });

  final String packageId;
  final String paymentReference;
  final UserEntitlementStatus status;
  final DateTime grantedAt;

  factory UserEntitlementModel.fromJson(Map<String, dynamic> json) {
    String requiredString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Invalid entitlement response field: $key');
      }
      return value;
    }

    final rawStatus = requiredString('status');
    final status = UserEntitlementStatus.values.where(
      (candidate) => candidate.name == rawStatus,
    );
    if (status.isEmpty) {
      throw const FormatException('Invalid entitlement status.');
    }

    final grantedAt = DateTime.tryParse(requiredString('grantedAt'));
    if (grantedAt == null) {
      throw const FormatException('Invalid entitlement timestamp.');
    }

    return UserEntitlementModel(
      packageId: requiredString('packageId'),
      paymentReference: requiredString('paymentReference'),
      status: status.first,
      grantedAt: grantedAt,
    );
  }

  UserEntitlement toEntity() {
    return UserEntitlement(
      packageId: packageId,
      paymentReference: paymentReference,
      status: status,
      grantedAt: grantedAt,
    );
  }
}
