import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/quiz_configuration.dart';

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
  }

  void setQuestionCount(int value) {
    state = state.copyWith(questionCount: value.clamp(1, 50));
  }

  void setDurationMinutes(int value) {
    state = state.copyWith(durationMinutes: value.clamp(1, 180));
  }

  void setMode(QuizMode value) {
    state = state.copyWith(mode: value);
  }

  void setExamCategory(String value) {
    state = state.copyWith(examCategoryId: value);
  }

  void setSubject(String value) {
    state = state.copyWith(
      subjectId: value,
      clearTopic: true,
      clearYear: true,
    );
  }

  void setTopic(String? value) {
    if (value == null) {
      state = state.copyWith(clearTopic: true);
      return;
    }
    state = state.copyWith(topic: value);
  }

  void setYear(int? value) {
    if (value == null) {
      state = state.copyWith(clearYear: true);
      return;
    }
    state = state.copyWith(year: value);
  }
}
