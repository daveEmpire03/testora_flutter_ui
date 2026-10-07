import '../entities/exam_category.dart';
import '../entities/exam_subject.dart';

abstract interface class ExamCatalogRepository {
  Future<List<ExamCategory>> getExamCategories();

  Future<List<ExamSubject>> getSubjects({required String examCategoryId});
}
