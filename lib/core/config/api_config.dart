import 'package:flutter/foundation.dart';

/// Runtime configuration for the Testora Cloudflare Worker API.
///
/// Override the local default with:
/// --dart-define=TESTORA_API_BASE_URL=https://<worker-host>/api/v1
abstract final class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'TESTORA_API_BASE_URL',
  );

  static String get baseUrl {
    final configured = _configuredBaseUrl.trim();
    final rawBaseUrl =
        configured.isNotEmpty
            ? configured
            : (kReleaseMode ? '' : 'http://127.0.0.1:8787/api/v1');

    if (rawBaseUrl.isEmpty) {
      throw StateError(
        'TESTORA_API_BASE_URL must be supplied for release builds.',
      );
    }

    final uri = Uri.tryParse(rawBaseUrl);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw StateError('TESTORA_API_BASE_URL is not a valid API base URL.');
    }

    if (kReleaseMode && uri.scheme != 'https') {
      throw StateError('Release builds must use an HTTPS API base URL.');
    }

    final normalizedPath =
        uri.path.endsWith('/') ? uri.path : '${uri.path}/';

    return uri.replace(path: normalizedPath).toString();
  }
}
