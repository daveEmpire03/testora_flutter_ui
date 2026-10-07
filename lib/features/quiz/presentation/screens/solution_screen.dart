import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:testora_flutter_ui/shared/testora_widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../providers/quiz_providers.dart';

class SolutionScreen extends ConsumerWidget {
  final String examId;
  final String attemptId;

  const SolutionScreen({
    super.key,
    required this.examId,
    required this.attemptId,
  });

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
        padding: const EdgeInsets.all(16),
        itemCount: result.questions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final q = result.questions[i];
          final chosen = result.answers[q.id];
          final correct = q.correctIndex;
          final isRight = chosen == correct;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    isRight
                        ? AppColors.success.withValues(alpha: .4)
                        : Colors.redAccent.withValues(alpha: .4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            isRight
                                ? AppColors.success.withValues(alpha: .15)
                                : Colors.redAccent.withValues(alpha: .15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isRight ? Icons.check_rounded : Icons.close_rounded,
                        size: 16,
                        color: isRight ? AppColors.success : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Question ${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  q.question,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _Line(
                  label: 'Your answer',
                  value:
                      chosen == null
                          ? 'Not answered'
                          : '${q.options[chosen].label}. ${q.options[chosen].text}',
                  color:
                      chosen == null
                          ? Colors.orange
                          : (isRight ? AppColors.success : Colors.redAccent),
                ),
                const SizedBox(height: 6),
                _Line(
                  label: 'Correct',
                  value:
                      '${q.options[correct].label}. ${q.options[correct].text}',
                  color: AppColors.success,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Line({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
