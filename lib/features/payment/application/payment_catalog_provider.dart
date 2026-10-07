import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/local_payment_catalog_repository.dart';
import '../domain/entities/exam_payment_package.dart';
import '../domain/repositories/payment_catalog_repository.dart';

final paymentCatalogRepositoryProvider = Provider<PaymentCatalogRepository>(
  (ref) => const LocalPaymentCatalogRepository(),
);

final paymentPackagesProvider = Provider<List<ExamPaymentPackage>>(
  (ref) => ref.watch(paymentCatalogRepositoryProvider).getPackages(),
);

final paymentPackageProvider =
    Provider.family<ExamPaymentPackage?, String>((ref, packageId) {
      return ref
          .watch(paymentCatalogRepositoryProvider)
          .getPackageById(packageId);
    });
