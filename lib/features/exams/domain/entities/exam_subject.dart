class ExamSubject {
  const ExamSubject({
    required this.id,
    required this.name,
    required this.description,
    required this.iconKey,
    this.topics = const <String>[],
    this.years = const <int>[],
  });

  final String id;
  final String name;
  final String description;
  final String iconKey;
  final List<String> topics;
  final List<int> years;
}
