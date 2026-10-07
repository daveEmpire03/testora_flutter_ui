import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/quiz_models.dart';
import 'question_repository_provider.dart';
import 'quiz_setup_provider.dart';

class QuizState {
  final List<QuizQuestion> questions;
  final Map<int, int> answers;
  final Set<int> bookmarked;
  final int currentIndex;
  final Duration remaining;
  final Duration totalTime;

  const QuizState({
    required this.questions,
    this.answers = const {},
    this.bookmarked = const {},
    this.currentIndex = 0,
    this.remaining = const Duration(minutes: 55),
    this.totalTime = const Duration(minutes: 55),
  });

  QuizQuestion get currentQuestion => questions[currentIndex];

  int? get selectedOption => answers[currentQuestion.id];

  bool get isBookmarked => bookmarked.contains(currentQuestion.id);

  bool get isLastQuestion => currentIndex == questions.length - 1;

  bool get isFirstQuestion => currentIndex == 0;

  int get answeredCount => answers.length;

  int get unansweredCount => questions.length - answers.length;

  double get progress =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  bool get isTimeWarning => remaining.inMinutes < 5;

  QuizState copyWith({
    List<QuizQuestion>? questions,
    Map<int, int>? answers,
    Set<int>? bookmarked,
    int? currentIndex,
    Duration? remaining,
    Duration? totalTime,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      bookmarked: bookmarked ?? this.bookmarked,
      currentIndex: currentIndex ?? this.currentIndex,
      remaining: remaining ?? this.remaining,
      totalTime: totalTime ?? this.totalTime,
    );
  }
}

final quizControllerProvider = NotifierProvider<QuizController, QuizState>(
  QuizController.new,
);

class QuizController extends Notifier<QuizState> {
  Timer? _timer;

  @override
  QuizState build() {
    final configuration = ref.watch(quizSetupProvider);
    final repository = ref.watch(questionRepositoryProvider);
    final questions = repository.getQuestions(configuration);
    final duration = Duration(minutes: configuration.durationMinutes);

    ref.onDispose(() => _timer?.cancel());

    final initialState = QuizState(
      questions: questions,
      remaining: duration,
      totalTime: duration,
    );

    if (questions.isNotEmpty) {
      _startTimer();
    }

    return initialState;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.remaining - const Duration(seconds: 1);

      if (next.inSeconds <= 0) {
        _timer?.cancel();
        state = state.copyWith(remaining: Duration.zero);
        return;
      }

      state = state.copyWith(remaining: next);
    });
  }

  void selectAnswer(int optionIndex) {
    if (state.questions.isEmpty) return;

    final updated = Map<int, int>.from(state.answers)
      ..[state.currentQuestion.id] = optionIndex;

    state = state.copyWith(answers: updated);
  }

  void clearAnswer() {
    if (state.questions.isEmpty) return;

    final updated = Map<int, int>.from(state.answers)
      ..remove(state.currentQuestion.id);

    state = state.copyWith(answers: updated);
  }

  void toggleBookmark() {
    if (state.questions.isEmpty) return;

    final updated = Set<int>.from(state.bookmarked);
    final id = state.currentQuestion.id;

    if (!updated.add(id)) {
      updated.remove(id);
    }

    state = state.copyWith(bookmarked: updated);
  }

  void next() {
    if (state.questions.isEmpty || state.isLastQuestion) return;
    state = state.copyWith(currentIndex: state.currentIndex + 1);
  }

  void previous() {
    if (state.questions.isEmpty || state.isFirstQuestion) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  void goTo(int index) {
    if (index < 0 || index >= state.questions.length) return;
    state = state.copyWith(currentIndex: index);
  }

  QuizResult submit() {
    _timer?.cancel();

    var correct = 0;
    for (final question in state.questions) {
      if (state.answers[question.id] == question.correctIndex) {
        correct++;
      }
    }

    return QuizResult(
      totalQuestions: state.questions.length,
      correctAnswers: correct,
      wrongAnswers: state.answers.length - correct,
      unanswered: state.questions.length - state.answers.length,
      timeSpent: state.totalTime - state.remaining,
      answers: Map.unmodifiable(state.answers),
      questions: state.questions,
    );
  }
}

final lastQuizResultProvider = NotifierProvider<LastQuizResult, QuizResult?>(
  LastQuizResult.new,
);

class LastQuizResult extends Notifier<QuizResult?> {
  @override
  QuizResult? build() => null;

  void set(QuizResult result) {
    state = result;
  }
}
