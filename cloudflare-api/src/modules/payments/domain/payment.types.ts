export type PaymentStatus = "initializing" | "pending" | "success" | "failed";

export interface PaymentRecord {
  reference: string;
  firebaseUid: string;
  packageId: string;
  amountKobo: number;
  currency: string;
  customerEmail: string;
  status: PaymentStatus;
  authorizationUrl: string | null;
  gatewayTransactionId: string | null;
  createdAt: string;
  updatedAt: string;
  paidAt: string | null;
}

export interface VerifiedGatewayTransaction {
  id: string | number;
  reference: string;
  status: string;
  amount: number;
  currency: string;
  customerEmail?: string;
}

export interface InitializeGatewayTransaction {
  email: string;
  amount: number;
  currency: "NGN";
  reference: string;
  callbackUrl?: string;
  metadata: { package_id: string; application: "testora" };
}

export interface InitializedGatewayTransaction {
  authorizationUrl: string;
  reference: string;
}

export interface PaymentGateway {
  initializeTransaction(input: InitializeGatewayTransaction): Promise<InitializedGatewayTransaction>;
  verifyTransaction(reference: string): Promise<VerifiedGatewayTransaction>;
}
