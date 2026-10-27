import '../entities/exam_payment_package.dart';

abstract interface class PaymentCatalogRepository {
  Future<List<ExamPaymentPackage>> getPackages();
  Future<ExamPaymentPackage?> getPackageById(String id);
}
