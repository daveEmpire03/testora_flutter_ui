import 'package:flutter_test/flutter_test.dart';
import 'package:testora_flutter_ui/features/quiz/data/repositories/local_question_repository.dart';
import 'package:testora_flutter_ui/features/quiz/data/sources/local_question_bank.dart';
import 'package:testora_flutter_ui/features/quiz/domain/quiz_configuration.dart';

void main() {
  group('localQuestionBank', () {
    test('contains production seed coverage', () {
      expect(localQuestionBank.length, greaterThanOrEqualTo(60));
    });

    test('uses unique ids and valid answer indexes', () {
      final ids = <int>{};

      for (final question in localQuestionBank) {
        expect(ids.add(question.id), isTrue, reason: 'Duplicate id: ${question.id}');
        expect(question.subjectId.trim(), isNotEmpty);
        expect(question.subject.trim(), isNotEmpty);
        expect(question.topic.trim(), isNotEmpty);
        expect(question.question.trim(), isNotEmpty);
        expect(question.options.length, 4);
        expect(question.correctIndex, inInclusiveRange(0, question.options.length - 1));
        expect(question.explanation.trim(), isNotEmpty);
      }
    });
  });

  group('LocalQuestionRepository', () {
    const repository = LocalQuestionRepository();

    test('filters questions by selected subject', () {
      const config = QuizConfiguration(
        subjectId: 'biology',
        questionCount: 5,
      );

      final questions = repository.getQuestions(config);

      expect(questions, isNotEmpty);
      expect(questions.length, lessThanOrEqualTo(5));
      expect(
        questions.every((question) => question.subjectId == 'biology'),
        isTrue,
      );
    });

    test('filters questions by topic when matching questions exist', () {
      const config = QuizConfiguration(
        subjectId: 'mathematics',
        topic: 'Algebra',
        questionCount: 5,
      );

      final questions = repository.getQuestions(config);

      expect(questions, isNotEmpty);
      expect(
        questions.every((question) => question.topic == 'Algebra'),
        isTrue,
      );
    });

    test('never exceeds requested question count', () {
      const config = QuizConfiguration(
        subjectId: 'english',
        questionCount: 2,
      );

      expect(repository.getQuestions(config).length, 2);
    });
  });
}
