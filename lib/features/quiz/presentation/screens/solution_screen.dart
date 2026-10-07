import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/testora_widgets.dart';
import '../../providers/quiz_providers.dart';

class SolutionScreen extends ConsumerWidget {
  const SolutionScreen({
    super.key,
    required this.examId,
    required this.attemptId,
  });

  final String examId;
  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastQuizResultProvider);

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Solutions')),
        body: TestoraEmptyState(
          icon: Icons.menu_book_outlined,
          title: 'No solutions',
          message: 'Complete a quiz to see the solutions here.',
          actionLabel: 'Go Home',
          onAction: () => context.go('/home'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Solutions')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.sp40,
        ),
        itemCount: result.questions.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final question = result.questions[index];
          final chosen = result.answers[question.id];
          final correct = question.correctIndex;
          final isRight = chosen == correct;

          return _SolutionCard(
            number: index + 1,
            isRight: isRight,
            topic: question.topic,
            sourceLabel: question.sourceLabel,
            question: question.question,
            yourAnswer:
                chosen == null
                    ? 'Not answered'
                    : '${question.options[chosen].label}. '
                        '${question.options[chosen].text}',
            correctAnswer:
                '${question.options[correct].label}. '
                '${question.options[correct].text}',
            explanation: question.explanation,
          );
        },
      ),
    );
  }
}

class _SolutionCard extends StatelessWidget {
  const _SolutionCard({
    required this.number,
    required this.isRight,
    required this.topic,
    required this.sourceLabel,
    required this.question,
    required this.yourAnswer,
    required this.correctAnswer,
    required this.explanation,
  });

  final int number;
  final bool isRight;
  final String topic;
  final String sourceLabel;
  final String question;
  final String yourAnswer;
  final String correctAnswer;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final statusColor = isRight ? AppColors.success : AppColors.error;

    return TestoraCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: statusColor.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRight ? Icons.check_rounded : Icons.close_rounded,
                  size: 17,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Question $number',
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TestoraBadge(label: topic),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            question,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _AnswerLine(
            label: 'Your answer',
            value: yourAnswer,
            color: isRight ? AppColors.success : AppColors.error,
          ),
          const SizedBox(height: AppSpacing.sm),
          _AnswerLine(
            label: 'Correct answer',
            value: correctAnswer,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: tokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: tokens.textPrimary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Explanation',
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  explanation,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            sourceLabel,
            style: TextStyle(
              color: tokens.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104,
          child: Text(
            label,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 11.5,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
