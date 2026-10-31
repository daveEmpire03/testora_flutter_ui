import type {
  InitializeGatewayTransaction,
  InitializedGatewayTransaction,
  PaymentGateway,
  VerifiedGatewayTransaction,
} from "../domain/payment.types";

export class PaystackGatewayError extends Error {
  constructor(message = "Paystack request failed.") {
    super(message);
    this.name = "PaystackGatewayError";
  }
}

interface PaystackEnvelope<T> {
  status?: boolean;
  message?: string;
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
  private readonly fetcher: (input: RequestInfo | URL, init?: RequestInit) => Promise<Response>;

  constructor(
    private readonly secretKey: string,
    fetcher?: typeof fetch,
  ) {
    // Wrap in an arrow so `fetch` is always invoked in the global scope,
    // not bound to a class instance. Cloudflare Workers throws "Illegal
    // invocation" when fetch is called with a non-global `this`.
    const baseFetcher = fetcher ?? fetch;
    this.fetcher = (input: RequestInfo | URL, init?: RequestInit) =>
      baseFetcher(input, init);
  }

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
      throw new PaystackGatewayError("Paystack did not return an authorization URL.");
    }

    let checkoutUrl: URL;
    try {
      checkoutUrl = new URL(authorizationUrl);
    } catch {
      throw new PaystackGatewayError("Invalid checkout URL returned by Paystack.");
    }

    if (
      checkoutUrl.protocol !== "https:" ||
      checkoutUrl.hostname !== "checkout.paystack.com"
    ) {
      throw new PaystackGatewayError("Untrusted checkout domain returned by Paystack.");
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
      throw new PaystackGatewayError("Invalid transaction data returned by Paystack.");
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
    } catch (error) {
      throw new PaystackGatewayError(
        "Network connection to Paystack failed: " +
          (error instanceof Error ? error.message : String(error)),
      );
    }

    let envelope: PaystackEnvelope<T>;
    try {
      envelope = (await response.json()) as PaystackEnvelope<T>;
    } catch {
      throw new PaystackGatewayError(
        `Paystack returned an unparseable response (HTTP ${response.status}).`,
      );
    }

    if (!response.ok || envelope.status !== true || !envelope.data) {
      const msg = envelope.message || `Paystack error (HTTP ${response.status})`;
      throw new PaystackGatewayError(msg);
    }

    return envelope;
  }
}
