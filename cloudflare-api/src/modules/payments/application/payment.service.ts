import { AppError } from "../../../shared/errors/app-error";
import type { PaymentRecord, PaymentGateway } from "../domain/payment.types";
import { D1PaymentRepository } from "../infrastructure/d1-payment.repository";

export async function applyVerifiedTransaction(
  repository: D1PaymentRepository,
  payment: PaymentRecord,
  gateway: PaymentGateway,
  options?: {
    webhookEventKey?: string;
    webhookEventType?: string;
  },
): Promise<PaymentRecord> {
  const verified = await gateway.verifyTransaction(payment.reference);

  if (
    verified.reference !== payment.reference ||
    verified.amount !== payment.amountKobo ||
    verified.currency !== payment.currency ||
    (verified.customerEmail !== undefined &&
      verified.customerEmail.toLowerCase() !== payment.customerEmail.toLowerCase())
  ) {
    throw new AppError(
      409,
      "PAYMENT_DETAILS_MISMATCH",
      "The verified transaction does not match this payment.",
    );
  }

  if (verified.status === "success") {
    return repository.markSucceeded({
      reference: payment.reference,
      gatewayTransactionId: String(verified.id),
      paidAt: new Date().toISOString(),
      webhookEventKey: options?.webhookEventKey,
      webhookEventType: options?.webhookEventType,
    });
  }

  if (
    verified.status === "failed" ||
    verified.status === "abandoned"
  ) {
    await repository.markFailed(payment.reference, new Date().toISOString());
  }

  return (await repository.findByReference(payment.reference)) ?? payment;
}
