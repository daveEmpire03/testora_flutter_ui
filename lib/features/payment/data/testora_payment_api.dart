import 'dart:convert';
import 'package:http/http.dart' as http;

/// Testora payment API client. Configure the base URL at build time:
/// --dart-define=TESTORA_API_BASE_URL=https://api.yourapp.com/api
class TestoraPaymentApi {
  TestoraPaymentApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ??
                const String.fromEnvironment(
                  'TESTORA_API_BASE_URL',
                  defaultValue: 'http://127.0.0.1:8000/api',
                ))
            .replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String _baseUrl;

  /// Fetches the list of active exam packages from the backend.
  Future<List<Map<String, dynamic>>> fetchPackages() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/packages/'),
      headers: const {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw const TestoraPaymentException('Unable to load exam packages.');
    }
    try {
      final value = jsonDecode(response.body);
      if (value is Map<String, dynamic>) {
        final results = value['results'];
        if (results is List) {
          return results.whereType<Map<String, dynamic>>().toList();
        }
      }
    } catch (_) {}
    throw const TestoraPaymentException(
      'The server returned an invalid packages response.',
    );
  }

  Future<Map<String, dynamic>> initialize({
    required String email,
    required String packageCode,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/payments/initialize/'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email.trim(), 'package_code': packageCode}),
    );
    final body = _decode(response);
    if (response.statusCode != 201) {
      throw TestoraPaymentException(_message(body, 'Unable to start payment.'));
    }
    return body;
  }

  Future<Map<String, dynamic>> verify(String reference) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/payments/verify/'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'reference': reference}),
    );
    final body = _decode(response);
    if (response.statusCode != 200 && response.statusCode != 202) {
      throw TestoraPaymentException(
        _message(body, 'Unable to verify payment.'),
      );
    }
    return body;
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final value = jsonDecode(response.body);
      if (value is Map<String, dynamic>) return value;
    } catch (_) {
      /* handled below */
    }
    if (response.statusCode >= 500) {
      throw const TestoraPaymentException(
        'Payment service is temporarily unavailable.',
      );
    }
    throw const TestoraPaymentException(
      'The payment service returned an invalid response.',
    );
  }

  String _message(Map<String, dynamic> body, String fallback) =>
      body['detail'] is String ? body['detail'] as String : fallback;

  void close() => _client.close();
}

class TestoraPaymentException implements Exception {
  const TestoraPaymentException(this.message);
  final String message;
  @override
  String toString() => message;
}
