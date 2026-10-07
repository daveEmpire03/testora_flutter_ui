class QuizOption {
  final String label;
  final String text;

  const QuizOption({required this.label, required this.text});
}

class QuizQuestion {
  final int id;
  final String subject;
  final String question;
  final List<QuizOption> options;
  final int correctIndex;

  const QuizQuestion({
    required this.id,
    required this.subject,
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unanswered;
  final Duration timeSpent;
  final Map<int, int> answers;
  final List<QuizQuestion> questions;

  const QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unanswered,
    required this.timeSpent,
    required this.answers,
    required this.questions,
  });

  double get accuracy =>
      totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;
}
