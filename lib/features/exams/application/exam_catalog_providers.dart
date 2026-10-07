import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/local_exam_catalog_repository.dart';
import '../domain/entities/exam_category.dart';
import '../domain/entities/exam_subject.dart';
import '../domain/repositories/exam_catalog_repository.dart';

final examCatalogRepositoryProvider = Provider<ExamCatalogRepository>(
  (ref) => const LocalExamCatalogRepository(),
);

final examCategoriesProvider = FutureProvider<List<ExamCategory>>((ref) {
  return ref.watch(examCatalogRepositoryProvider).getExamCategories();
});

final examSubjectsProvider =
    FutureProvider.family<List<ExamSubject>, String>((ref, examCategoryId) {
      return ref
          .watch(examCatalogRepositoryProvider)
          .getSubjects(examCategoryId: examCategoryId);
    });


final selectedExamCategoryProvider =
    NotifierProvider<SelectedExamCategoryController, String>(
      SelectedExamCategoryController.new,
    );

class SelectedExamCategoryController extends Notifier<String> {
  @override
  String build() => 'general';

  void select(String examCategoryId) {
    state = examCategoryId;
  }
}
