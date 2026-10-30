export interface UserEntitlement {
  packageId: string;
  paymentReference: string;
  status: "active" | "revoked";
  grantedAt: string;
}

interface EntitlementRow {
  package_id: string;
  payment_reference: string;
  status: "active" | "revoked";
  granted_at: string;
}

export class D1EntitlementsRepository {
  constructor(private readonly db: D1Database) {}

  async listForUser(firebaseUid: string): Promise<UserEntitlement[]> {
    const result = await this.db
      .prepare(
        "SELECT package_id, payment_reference, status, granted_at " +
        "FROM user_entitlements WHERE firebase_uid = ? ORDER BY granted_at DESC",
      )
      .bind(firebaseUid)
      .all<EntitlementRow>();

    return (result.results ?? []).map((row) => ({
      packageId: row.package_id,
      paymentReference: row.payment_reference,
      status: row.status,
      grantedAt: row.granted_at,
    }));
  }

  async hasActiveEntitlement(
    firebaseUid: string,
    packageId: string,
  ): Promise<boolean> {
    const row = await this.db
      .prepare(
        "SELECT 1 AS active FROM user_entitlements " +
        "WHERE firebase_uid = ? AND package_id = ? AND status = 'active' LIMIT 1",
      )
      .bind(firebaseUid, packageId)
      .first<{ active: number }>();

    return row?.active === 1;
  }
}
