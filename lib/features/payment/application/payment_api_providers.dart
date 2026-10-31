import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/repositories/cloudflare_payment_repository.dart';
import '../domain/entities/payment_transaction.dart';
import '../domain/entities/user_entitlement.dart';
import '../domain/repositories/payment_repository.dart';

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

final paymentHistoryProvider =
    FutureProvider.autoDispose<List<PaymentTransaction>>((ref) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getPaymentHistory();
});

final userEntitlementsProvider =
    FutureProvider.autoDispose<List<UserEntitlement>>((ref) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getUserEntitlements();
});
