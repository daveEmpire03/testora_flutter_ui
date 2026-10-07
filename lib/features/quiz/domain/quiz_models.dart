class QuizOption {
  final String label;
  final String text;

  const QuizOption({required this.label, required this.text});
}

class QuizQuestion {
  final int id;
  final String subjectId;
  final String subject;
  final String topic;
  final String question;
  final List<QuizOption> options;
  final int correctIndex;
  final String explanation;
  final String sourceLabel;

  const QuizQuestion({
    required this.id,
    required this.subjectId,
    required this.subject,
    required this.topic,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.sourceLabel = 'Testora Original • Exam-standard practice',
  });

  QuizOption get correctOption => options[correctIndex];
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
