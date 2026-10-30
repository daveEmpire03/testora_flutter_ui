export interface PaymentPackage {
  id: string;
  name: string;
  amountKobo: number;
  currency: "NGN";
}

const PAYMENT_PACKAGES: Readonly<Record<string, PaymentPackage>> = {
  utme: { id: "utme", name: "UTME", amountKobo: 200_000, currency: "NGN" },
  waec: { id: "waec", name: "WAEC", amountKobo: 400_000, currency: "NGN" },
  "post-utme": { id: "post-utme", name: "Post-UTME", amountKobo: 300_000, currency: "NGN" },
  postgraduate: { id: "postgraduate", name: "Postgraduate", amountKobo: 500_000, currency: "NGN" },
};

export function getPaymentPackage(packageId: string): PaymentPackage | undefined {
  return PAYMENT_PACKAGES[packageId];
}

export function listPaymentPackages(): PaymentPackage[] {
  return Object.values(PAYMENT_PACKAGES);
}
