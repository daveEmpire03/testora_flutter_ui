import '../quiz_configuration.dart';
import '../quiz_models.dart';

abstract interface class QuestionRepository {
  List<QuizQuestion> getQuestions(QuizConfiguration configuration);
}
