enum QuizMode { multiple, single, flash }

class QuizConfiguration {
  const QuizConfiguration({
    this.questionCount = 5,
    this.durationMinutes = 10,
    this.mode = QuizMode.multiple,
    this.examCategoryId = 'general',
    this.subjectId = 'biology',
    this.topic,
    this.year,
  });

  final int questionCount;
  final int durationMinutes;
  final QuizMode mode;
  final String examCategoryId;
  final String subjectId;
  final String? topic;
  final int? year;

  QuizConfiguration copyWith({
    int? questionCount,
    int? durationMinutes,
    QuizMode? mode,
    String? examCategoryId,
    String? subjectId,
    String? topic,
    int? year,
    bool clearTopic = false,
    bool clearYear = false,
  }) {
    return QuizConfiguration(
      questionCount: questionCount ?? this.questionCount,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      mode: mode ?? this.mode,
      examCategoryId: examCategoryId ?? this.examCategoryId,
      subjectId: subjectId ?? this.subjectId,
      topic: clearTopic ? null : (topic ?? this.topic),
      year: clearYear ? null : (year ?? this.year),
    );
  }
}
