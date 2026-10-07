class ExamPaymentPackage {
  const ExamPaymentPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.priceNaira,
    required this.iconKey,
  });

  final String id;
  final String name;
  final String description;
  final int priceNaira;
  final String iconKey;

  int get priceKobo => priceNaira * 100;
}
