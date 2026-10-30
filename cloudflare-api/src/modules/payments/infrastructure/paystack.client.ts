import type {
  InitializeGatewayTransaction,
  InitializedGatewayTransaction,
  PaymentGateway,
  VerifiedGatewayTransaction,
} from "../domain/payment.types";

export class PaystackGatewayError extends Error {
  constructor() {
    super("Paystack request failed.");
    this.name = "PaystackGatewayError";
  }
}

interface PaystackEnvelope<T> {
  status?: boolean;
  data?: T;
}

interface PaystackInitializeData {
  authorization_url?: string;
  reference?: string;
}

interface PaystackVerifyData {
  id?: string | number;
  reference?: string;
  status?: string;
  amount?: number;
  currency?: string;
  customer?: { email?: string };
}

export class PaystackClient implements PaymentGateway {
  constructor(
    private readonly secretKey: string,
    private readonly fetcher: typeof fetch = fetch,
  ) {}

  async initializeTransaction(
    input: InitializeGatewayTransaction,
  ): Promise<InitializedGatewayTransaction> {
    const body: Record<string, unknown> = {
      email: input.email,
      amount: input.amount,
      currency: input.currency,
      reference: input.reference,
      metadata: input.metadata,
    };

    if (input.callbackUrl) body.callback_url = input.callbackUrl;

    const envelope = await this.request<PaystackInitializeData>(
      "https://api.paystack.co/transaction/initialize",
      { method: "POST", body: JSON.stringify(body) },
    );

    const authorizationUrl = envelope.data?.authorization_url;
    const reference = envelope.data?.reference;

    if (typeof authorizationUrl !== "string" || typeof reference !== "string") {
      throw new PaystackGatewayError();
    }

    let checkoutUrl: URL;
    try {
      checkoutUrl = new URL(authorizationUrl);
    } catch {
      throw new PaystackGatewayError();
    }

    if (
      checkoutUrl.protocol !== "https:" ||
      checkoutUrl.hostname !== "checkout.paystack.com"
    ) {
      throw new PaystackGatewayError();
    }

    return { authorizationUrl: checkoutUrl.toString(), reference };
  }

  async verifyTransaction(reference: string): Promise<VerifiedGatewayTransaction> {
    const envelope = await this.request<PaystackVerifyData>(
      "https://api.paystack.co/transaction/verify/" + encodeURIComponent(reference),
      { method: "GET" },
    );

    const data = envelope.data;
    if (
      (typeof data?.id !== "string" && typeof data?.id !== "number") ||
      typeof data.reference !== "string" ||
      typeof data.status !== "string" ||
      typeof data.amount !== "number" ||
      typeof data.currency !== "string"
    ) {
      throw new PaystackGatewayError();
    }

    return {
      id: data.id,
      reference: data.reference,
      status: data.status,
      amount: data.amount,
      currency: data.currency,
      customerEmail: typeof data.customer?.email === "string"
        ? data.customer.email
        : undefined,
    };
  }

  private async request<T>(url: string, init: RequestInit): Promise<PaystackEnvelope<T>> {
    let response: Response;

    try {
      response = await this.fetcher(url, {
        ...init,
        headers: {
          Authorization: "Bearer " + this.secretKey,
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        signal: AbortSignal.timeout(15_000),
      });
    } catch {
      throw new PaystackGatewayError();
    }

    let envelope: PaystackEnvelope<T>;
    try {
      envelope = (await response.json()) as PaystackEnvelope<T>;
    } catch {
      throw new PaystackGatewayError();
    }

    if (!response.ok || envelope.status !== true || !envelope.data) {
      throw new PaystackGatewayError();
    }

    return envelope;
  }
}
