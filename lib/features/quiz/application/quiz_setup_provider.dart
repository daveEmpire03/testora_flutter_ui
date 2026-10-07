import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/quiz_configuration.dart';
import 'question_repository_provider.dart';

final quizSetupProvider =
    NotifierProvider<QuizSetupController, QuizConfiguration>(
      QuizSetupController.new,
    );

class QuizSetupController extends Notifier<QuizConfiguration> {
  @override
  QuizConfiguration build() => const QuizConfiguration();

  void resetForExam(String examCategoryId, {String? subjectId}) {
    state = QuizConfiguration(
      examCategoryId: examCategoryId,
      subjectId: subjectId ?? 'biology',
    );
    _clampQuestionCountToAvailability();
  }

  void setQuestionCount(int value) {
    final available = _availableQuestionCount();
    final maxAllowed = available > 0 ? available : 1;

    state = state.copyWith(
      questionCount: value.clamp(1, maxAllowed).toInt(),
    );
  }

  void setDurationMinutes(int value) {
    state = state.copyWith(
      durationMinutes: value.clamp(1, 180).toInt(),
    );
  }

  void setMode(QuizMode value) {
    state = state.copyWith(mode: value);
  }

  void setExamCategory(String value) {
    state = state.copyWith(examCategoryId: value);
    _clampQuestionCountToAvailability();
  }

  void setSubject(String value) {
    state = state.copyWith(
      subjectId: value,
      clearTopic: true,
      clearYear: true,
    );
    _clampQuestionCountToAvailability();
  }

  void setTopic(String? value) {
    state =
        value == null
            ? state.copyWith(clearTopic: true)
            : state.copyWith(topic: value);

    _clampQuestionCountToAvailability();
  }

  void setYear(int? value) {
    state =
        value == null
            ? state.copyWith(clearYear: true)
            : state.copyWith(year: value);
  }

  int _availableQuestionCount() {
    final repository = ref.read(questionRepositoryProvider);
    final probe = state.copyWith(questionCount: 1000);
    return repository.getQuestions(probe).length;
  }

  void _clampQuestionCountToAvailability() {
    final available = _availableQuestionCount();

    if (available <= 0) {
      state = state.copyWith(questionCount: 1);
      return;
    }

    if (state.questionCount > available) {
      state = state.copyWith(questionCount: available);
    }
  }
}
