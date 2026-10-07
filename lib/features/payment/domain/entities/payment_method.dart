enum PaymentMethodType {
  paystack,
  manualTransfer,
}

extension PaymentMethodTypeLabel on PaymentMethodType {
  String get label {
    switch (this) {
      case PaymentMethodType.paystack:
        return 'Paystack';
      case PaymentMethodType.manualTransfer:
        return 'Manual Transfer';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethodType.paystack:
        return 'Pay securely online with card, bank or supported Paystack methods.';
      case PaymentMethodType.manualTransfer:
        return 'Transfer manually and submit your payment reference for verification.';
    }
  }
}
