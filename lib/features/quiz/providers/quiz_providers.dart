import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/quiz_models.dart';

// =============================================================================
// MOCK QUESTIONS
// =============================================================================

const _mockQuestions = <QuizQuestion>[
  QuizQuestion(
    id: 1,
    subject: 'Mathematics',
    question: 'What is the value of x in the equation 2x + 5 = 15?',
    correctIndex: 1,
    options: [
      QuizOption(label: 'A', text: '3'),
      QuizOption(label: 'B', text: '5'),
      QuizOption(label: 'C', text: '7'),
      QuizOption(label: 'D', text: '10'),
    ],
  ),
  QuizQuestion(
    id: 2,
    subject: 'Mathematics',
    question: 'What is 12 × 8?',
    correctIndex: 2,
    options: [
      QuizOption(label: 'A', text: '86'),
      QuizOption(label: 'B', text: '92'),
      QuizOption(label: 'C', text: '96'),
      QuizOption(label: 'D', text: '108'),
    ],
  ),
  QuizQuestion(
    id: 3,
    subject: 'Mathematics',
    question: 'What is the square root of 144?',
    correctIndex: 2,
    options: [
      QuizOption(label: 'A', text: '10'),
      QuizOption(label: 'B', text: '11'),
      QuizOption(label: 'C', text: '12'),
      QuizOption(label: 'D', text: '14'),
    ],
  ),
  QuizQuestion(
    id: 4,
    subject: 'Mathematics',
    question: 'Simplify: 3(2x + 4).',
    correctIndex: 1,
    options: [
      QuizOption(label: 'A', text: '6x + 4'),
      QuizOption(label: 'B', text: '6x + 12'),
      QuizOption(label: 'C', text: '5x + 12'),
      QuizOption(label: 'D', text: '6x + 7'),
    ],
  ),
  QuizQuestion(
    id: 5,
    subject: 'Mathematics',
    question: 'If y = 4x and x = 3, what is y?',
    correctIndex: 2,
    options: [
      QuizOption(label: 'A', text: '7'),
      QuizOption(label: 'B', text: '8'),
      QuizOption(label: 'C', text: '12'),
      QuizOption(label: 'D', text: '16'),
    ],
  ),
];

// =============================================================================
// STATE
// =============================================================================

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
  double get progress => (currentIndex + 1) / questions.length;
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

// =============================================================================
// CONTROLLER
// =============================================================================

final quizControllerProvider = NotifierProvider<QuizController, QuizState>(
  QuizController.new,
);

class QuizController extends Notifier<QuizState> {
  Timer? _timer;

  @override
  QuizState build() {
    ref.onDispose(() => _timer?.cancel());
    _startTimer();
    return const QuizState(questions: _mockQuestions);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.remaining - const Duration(seconds: 1);
      if (next.inSeconds <= 0) {
        _timer?.cancel();
        state = state.copyWith(remaining: Duration.zero);
      } else {
        state = state.copyWith(remaining: next);
      }
    });
  }

  void selectAnswer(int optionIndex) {
    final updated = Map<int, int>.from(state.answers)
      ..[state.currentQuestion.id] = optionIndex;
    state = state.copyWith(answers: updated);
  }

  void clearAnswer() {
    final updated = Map<int, int>.from(state.answers)
      ..remove(state.currentQuestion.id);
    state = state.copyWith(answers: updated);
  }

  void toggleBookmark() {
    final updated = Set<int>.from(state.bookmarked);
    final id = state.currentQuestion.id;
    if (!updated.add(id)) updated.remove(id);
    state = state.copyWith(bookmarked: updated);
  }

  void next() {
    if (state.isLastQuestion) return;
    state = state.copyWith(currentIndex: state.currentIndex + 1);
  }

  void previous() {
    if (state.isFirstQuestion) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  void goTo(int index) {
    if (index < 0 || index >= state.questions.length) return;
    state = state.copyWith(currentIndex: index);
  }

  QuizResult submit() {
    _timer?.cancel();

    var correct = 0;
    for (final q in state.questions) {
      if (state.answers[q.id] == q.correctIndex) correct++;
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

// =============================================================================
// LAST RESULT
// =============================================================================

final lastQuizResultProvider = NotifierProvider<LastQuizResult, QuizResult?>(
  LastQuizResult.new,
);

class LastQuizResult extends Notifier<QuizResult?> {
  @override
  QuizResult? build() => null;

  void set(QuizResult result) => state = result;
}
