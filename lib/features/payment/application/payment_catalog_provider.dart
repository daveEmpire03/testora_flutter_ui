import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/remote_payment_catalog_repository.dart';
import '../data/testora_payment_api.dart';
import '../domain/entities/exam_payment_package.dart';
import '../domain/repositories/payment_catalog_repository.dart';

/// Managed API client — closed automatically when the provider is disposed.
final paymentApiProvider = Provider<TestoraPaymentApi>((ref) {
  final api = TestoraPaymentApi();
  ref.onDispose(api.close);
  return api;
});

final paymentCatalogRepositoryProvider = Provider<PaymentCatalogRepository>(
  (ref) => RemotePaymentCatalogRepository(ref.watch(paymentApiProvider)),
);

/// Live list of exam packages fetched from the backend.
final paymentPackagesProvider = FutureProvider<List<ExamPaymentPackage>>(
  (ref) => ref.watch(paymentCatalogRepositoryProvider).getPackages(),
);

/// Single exam package by id, resolved from the live list.
final paymentPackageProvider =
    FutureProvider.family<ExamPaymentPackage?, String>((ref, packageId) async {
      final packages = await ref.watch(paymentPackagesProvider.future);
      for (final p in packages) {
        if (p.id == packageId) return p;
      }
      return null;
    });

