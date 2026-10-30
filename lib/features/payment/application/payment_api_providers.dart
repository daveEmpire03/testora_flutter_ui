import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/api_config.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/repositories/payment_repository.dart';
import '../data/repositories/cloudflare_payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        Headers.acceptHeader: Headers.jsonContentType,
      },
    ),
  );

  ref.onDispose(() => dio.close(force: true));

  return CloudflarePaymentRepository(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    dio: dio,
  );
});
