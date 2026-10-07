import '../../domain/quiz_configuration.dart';
import '../../domain/quiz_models.dart';
import '../../domain/repositories/question_repository.dart';
import '../sources/local_question_bank.dart';

class LocalQuestionRepository implements QuestionRepository {
  const LocalQuestionRepository();

  @override
  List<QuizQuestion> getQuestions(QuizConfiguration configuration) {
    var matches = localQuestionBank
        .where((question) => question.subjectId == configuration.subjectId)
        .toList(growable: false);

    final topic = configuration.topic?.trim();
    if (topic != null && topic.isNotEmpty) {
      final topicMatches = matches
          .where(
            (question) =>
                question.topic.toLowerCase() == topic.toLowerCase(),
          )
          .toList(growable: false);

      if (topicMatches.isNotEmpty) {
        matches = topicMatches;
      }
    }

    if (matches.isEmpty) {
      return const <QuizQuestion>[];
    }

    final requestedCount = configuration.questionCount;
    final count = requestedCount < matches.length
        ? requestedCount
        : matches.length;

    return List<QuizQuestion>.unmodifiable(matches.take(count));
  }
}
