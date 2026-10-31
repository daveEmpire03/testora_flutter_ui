enum UserEntitlementStatus {
  active,
  revoked,
}

class UserEntitlement {
  const UserEntitlement({
    required this.packageId,
    required this.paymentReference,
    required this.status,
    required this.grantedAt,
  });

  final String packageId;
  final String paymentReference;
  final UserEntitlementStatus status;
  final DateTime grantedAt;

  bool get isActive => status == UserEntitlementStatus.active;
}
