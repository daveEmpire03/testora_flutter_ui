import '../entities/exam_payment_package.dart';

abstract interface class PaymentCatalogRepository {
  List<ExamPaymentPackage> getPackages();

  ExamPaymentPackage? getPackageById(String id);
}
