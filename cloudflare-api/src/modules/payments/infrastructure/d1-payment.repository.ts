import type { PaymentRecord, PaymentStatus } from "../domain/payment.types";

interface PaymentRow {
  reference: string;
  firebase_uid: string;
  package_id: string;
  amount_kobo: number;
  currency: string;
  customer_email: string;
  status: PaymentStatus;
  authorization_url: string | null;
  gateway_transaction_id: string | null;
  created_at: string;
  updated_at: string;
  paid_at: string | null;
}

export class D1PaymentRepository {
  constructor(private readonly db: D1Database) {}

  async createInitializingPayment(input: {
    reference: string;
    firebaseUid: string;
    packageId: string;
    amountKobo: number;
    currency: string;
    customerEmail: string;
    createdAt: string;
  }): Promise<void> {
    const result = await this.db
      .prepare(
        "INSERT INTO payment_transactions " +
        "(reference, firebase_uid, package_id, amount_kobo, currency, customer_email, status, created_at, updated_at) " +
        "VALUES (?, ?, ?, ?, ?, ?, 'initializing', ?, ?)",
      )
      .bind(
        input.reference,
        input.firebaseUid,
        input.packageId,
        input.amountKobo,
        input.currency,
        input.customerEmail,
        input.createdAt,
        input.createdAt,
      )
      .run();

    if (!result.success || result.meta.changes !== 1) {
      throw new Error("Unable to create payment record.");
    }
  }

  async attachCheckoutUrl(
    reference: string,
    authorizationUrl: string,
    updatedAt: string,
  ): Promise<void> {
    await this.db
      .prepare(
        "UPDATE payment_transactions SET authorization_url = ?, " +
        "status = CASE WHEN status = 'initializing' THEN 'pending' ELSE status END, " +
        "updated_at = ? WHERE reference = ? AND status IN ('initializing', 'success')",
      )
      .bind(authorizationUrl, updatedAt, reference)
      .run();
  }

  async markFailed(reference: string, updatedAt: string): Promise<void> {
    await this.db
      .prepare(
        "UPDATE payment_transactions SET status = 'failed', updated_at = ? " +
        "WHERE reference = ? AND status IN ('initializing', 'pending')",
      )
      .bind(updatedAt, reference)
      .run();
  }

  async findByReference(reference: string): Promise<PaymentRecord | null> {
    const row = await this.db
      .prepare("SELECT * FROM payment_transactions WHERE reference = ? LIMIT 1")
      .bind(reference)
      .first<PaymentRow>();

    return row ? this.toPaymentRecord(row) : null;
  }

  async listUserPayments(firebaseUid: string): Promise<PaymentRecord[]> {
    const rows = await this.db
      .prepare(
        "SELECT * FROM payment_transactions " +
        "WHERE firebase_uid = ? ORDER BY created_at DESC LIMIT 50",
      )
      .bind(firebaseUid)
      .all<PaymentRow>();

    return (rows.results ?? []).map((row) => this.toPaymentRecord(row));
  }

  async findOwnedPayment(
    reference: string,
    firebaseUid: string,
  ): Promise<PaymentRecord | null> {
    const row = await this.db
      .prepare(
        "SELECT * FROM payment_transactions " +
        "WHERE reference = ? AND firebase_uid = ? LIMIT 1",
      )
      .bind(reference, firebaseUid)
      .first<PaymentRow>();

    return row ? this.toPaymentRecord(row) : null;
  }

  async markSucceeded(input: {
    reference: string;
    gatewayTransactionId: string;
    paidAt: string;
    webhookEventKey?: string;
    webhookEventType?: string;
  }): Promise<PaymentRecord> {
    const statements = [
      this.db
        .prepare(
          "UPDATE payment_transactions SET status = 'success', " +
          "gateway_transaction_id = ?, paid_at = COALESCE(paid_at, ?), updated_at = ? " +
          "WHERE reference = ? AND status IN ('initializing', 'pending', 'failed')",
        )
        .bind(
          input.gatewayTransactionId,
          input.paidAt,
          input.paidAt,
          input.reference,
        ),
      this.db
        .prepare(
          "INSERT INTO user_entitlements " +
          "(firebase_uid, package_id, payment_reference, status, granted_at) " +
          "SELECT firebase_uid, package_id, reference, 'active', ? " +
          "FROM payment_transactions WHERE reference = ? AND status = 'success' " +
          "ON CONFLICT(firebase_uid, package_id) DO UPDATE SET " +
          "payment_reference = excluded.payment_reference, status = 'active', " +
          "granted_at = CASE " +
          "WHEN user_entitlements.payment_reference = excluded.payment_reference " +
          "THEN user_entitlements.granted_at ELSE excluded.granted_at END",
        )
        .bind(input.paidAt, input.reference),
    ];

    if (input.webhookEventKey && input.webhookEventType) {
      statements.push(
        this.db
          .prepare(
            "INSERT OR IGNORE INTO payment_webhook_events " +
            "(event_key, reference, event_type, received_at) VALUES (?, ?, ?, ?)",
          )
          .bind(
            input.webhookEventKey,
            input.reference,
            input.webhookEventType,
            input.paidAt,
          ),
      );
    }

    await this.db.batch(statements);

    const payment = await this.findByReference(input.reference);
    if (!payment || payment.status !== "success") {
      throw new Error("Verified payment could not be committed.");
    }

    return payment;
  }

  private toPaymentRecord(row: PaymentRow): PaymentRecord {
    return {
      reference: row.reference,
      firebaseUid: row.firebase_uid,
      packageId: row.package_id,
      amountKobo: row.amount_kobo,
      currency: row.currency,
      customerEmail: row.customer_email,
      status: row.status,
      authorizationUrl: row.authorization_url,
      gatewayTransactionId: row.gateway_transaction_id,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
      paidAt: row.paid_at,
    };
  }
}
