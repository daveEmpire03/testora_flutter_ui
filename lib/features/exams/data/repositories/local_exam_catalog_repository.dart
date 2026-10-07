import '../../domain/entities/exam_category.dart';
import '../../domain/entities/exam_subject.dart';
import '../../domain/repositories/exam_catalog_repository.dart';

class LocalExamCatalogRepository implements ExamCatalogRepository {
  const LocalExamCatalogRepository();

  static const _categories = <ExamCategory>[
    ExamCategory(
      id: 'general',
      name: 'General',
      shortCode: 'G',
      description: 'General academic practice',
    ),
    ExamCategory(
      id: 'utme',
      name: 'UTME',
      shortCode: 'U',
      description: 'JAMB / UTME preparation',
    ),
    ExamCategory(
      id: 'waec',
      name: 'WAEC',
      shortCode: 'W',
      description: 'West African examinations',
    ),
    ExamCategory(
      id: 'post-utme',
      name: 'Post-UTME',
      shortCode: 'P',
      description: 'University screening practice',
    ),
    ExamCategory(
      id: 'postgraduate',
      name: 'Postgraduate',
      shortCode: 'PG',
      description: 'Postgraduate entrance practice',
    ),
  ];

  static const _subjects = <ExamSubject>[
    ExamSubject(
      id: 'aptitude-test',
      name: 'Aptitude Test',
      description: 'Logic, reasoning & aptitude',
      iconKey: 'psychology',
      topics: ['Verbal Reasoning', 'Quantitative Reasoning', 'Logic'],
    ),
    ExamSubject(
      id: 'biology',
      name: 'Biology',
      description: 'Life & living systems',
      iconKey: 'eco',
      topics: ['Cell Biology', 'Genetics', 'Ecology', 'Human Biology'],
    ),
    ExamSubject(
      id: 'chemistry',
      name: 'Chemistry',
      description: 'Matter & reactions',
      iconKey: 'science',
      topics: ['Atomic Structure', 'Stoichiometry', 'Organic Chemistry'],
    ),
    ExamSubject(
      id: 'crk',
      name: 'CRK',
      description: 'Christian religious knowledge',
      iconKey: 'book',
      topics: ['Old Testament', 'New Testament', 'Christian Living'],
    ),
    ExamSubject(
      id: 'current-affairs',
      name: 'Current Affairs',
      description: 'Nigeria, Africa & world affairs',
      iconKey: 'newspaper',
      topics: ['Nigeria', 'Africa', 'World', 'Government'],
    ),
    ExamSubject(
      id: 'english',
      name: 'English Language',
      description: 'Grammar & comprehension',
      iconKey: 'translate',
      topics: ['Comprehension', 'Lexis', 'Grammar', 'Oral English'],
    ),
    ExamSubject(
      id: 'economics',
      name: 'Economics',
      description: 'Markets & resources',
      iconKey: 'economics',
      topics: ['Demand & Supply', 'Money', 'Public Finance', 'Trade'],
    ),
    ExamSubject(
      id: 'geography',
      name: 'Geography',
      description: 'People, places & environment',
      iconKey: 'public',
      topics: ['Physical Geography', 'Human Geography', 'Map Reading'],
    ),
    ExamSubject(
      id: 'government',
      name: 'Government',
      description: 'Civics & political systems',
      iconKey: 'government',
      topics: ['Constitution', 'Political Systems', 'Public Administration'],
    ),
    ExamSubject(
      id: 'literature',
      name: 'Literature',
      description: 'Texts & interpretation',
      iconKey: 'library',
      topics: ['Prose', 'Drama', 'Poetry', 'Literary Appreciation'],
    ),
    ExamSubject(
      id: 'mathematics',
      name: 'Mathematics',
      description: 'Numbers & problem solving',
      iconKey: 'calculate',
      topics: ['Algebra', 'Geometry', 'Statistics', 'Trigonometry'],
    ),
    ExamSubject(
      id: 'physics',
      name: 'Physics',
      description: 'Motion, energy & matter',
      iconKey: 'bolt',
      topics: ['Mechanics', 'Waves', 'Electricity', 'Modern Physics'],
    ),
    ExamSubject(
      id: 'civic-education',
      name: 'Civic Education',
      description: 'Citizenship & society',
      iconKey: 'groups',
      topics: ['Citizenship', 'Human Rights', 'National Values'],
    ),
    ExamSubject(
      id: 'computer-studies',
      name: 'Computer Studies',
      description: 'Computing fundamentals',
      iconKey: 'computer',
      topics: ['Hardware', 'Software', 'Networking', 'Data'],
    ),
    ExamSubject(
      id: 'hausa',
      name: 'Hausa',
      description: 'Language & literature',
      iconKey: 'language',
      topics: ['Grammar', 'Comprehension', 'Literature'],
    ),
    ExamSubject(
      id: 'technical-drawing',
      name: 'Technical Drawing',
      description: 'Drawing & design principles',
      iconKey: 'architecture',
      topics: ['Projection', 'Geometry', 'Technical Sketching'],
    ),
    ExamSubject(
      id: 'home-economics',
      name: 'Home Economics',
      description: 'Home & resource management',
      iconKey: 'home',
      topics: ['Family Living', 'Clothing', 'Nutrition'],
    ),
    ExamSubject(
      id: 'food-nutrition',
      name: 'Food and Nutrition',
      description: 'Food science & nutrition',
      iconKey: 'restaurant',
      topics: ['Nutrients', 'Meal Planning', 'Food Safety'],
    ),
    ExamSubject(
      id: 'book-keeping',
      name: 'Book Keeping',
      description: 'Accounting foundations',
      iconKey: 'receipt',
      topics: ['Ledger', 'Cash Book', 'Trial Balance'],
    ),
  ];

  static final _years = List<int>.unmodifiable(
    List<int>.generate(15, (index) => 2026 - index),
  );

  @override
  Future<List<ExamCategory>> getExamCategories() async => _categories;

  @override
  Future<List<ExamSubject>> getSubjects({
    required String examCategoryId,
  }) async {
    return _subjects
        .map(
          (subject) => ExamSubject(
            id: subject.id,
            name: subject.name,
            description: subject.description,
            iconKey: subject.iconKey,
            topics: subject.topics,
            years: _years,
          ),
        )
        .toList(growable: false);
  }
}
