import 'package:url_launcher/url_launcher.dart';
import 'testora_payment_api.dart';

/// Coordinates hosted Paystack checkout. Call verifyPendingPayment after the app
/// resumes from the browser/callback; the backend, not this client, decides success.
class TestoraPaystackCheckout {
  TestoraPaystackCheckout(this._api);
  final TestoraPaymentApi _api;

  Future<PendingTestoraPayment> begin({required String email, required String packageCode}) async {
    final result = await _api.initialize(email: email, packageCode: packageCode);
    final rawUrl = result['authorization_url'];
    final rawReference = result['reference'];
    final uri = Uri.tryParse(rawUrl is String ? rawUrl : '');
    if (uri == null || uri.scheme != 'https' || uri.host != 'checkout.paystack.com' || rawReference is! String) {
      throw const TestoraPaymentException('The payment provider returned an invalid checkout URL.');
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) throw const TestoraPaymentException('Could not open Paystack checkout. Please try again.');
    return PendingTestoraPayment(reference: rawReference, packageCode: packageCode);
  }

  Future<Map<String, dynamic>> verifyPendingPayment(PendingTestoraPayment pending) => _api.verify(pending.reference);
}

class PendingTestoraPayment {
  const PendingTestoraPayment({required this.reference, required this.packageCode});
  final String reference;
  final String packageCode;
}
