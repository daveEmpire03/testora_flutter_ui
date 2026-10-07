import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:testora_flutter_ui/shared/testora_widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/quiz_models.dart';
import '../../providers/quiz_providers.dart';

class ResultScreen extends ConsumerWidget {
  final String examId;
  final String attemptId;

  const ResultScreen({
    super.key,
    required this.examId,
    required this.attemptId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastQuizResultProvider);

    if (result == null) {
      return Scaffold(
        body: TestoraEmptyState(
          icon: Icons.assignment_outlined,
          title: 'No result found',
          message:
              "We couldn't find a completed quiz to show here. Start a new practice session.",
          actionLabel: 'Go Home',
          onAction: () => context.go('/home'),
        ),
      );
    }

    final accuracy = (result.accuracy * 100).round();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 36),
          children: [
            _Header(accuracy: accuracy),
            const SizedBox(height: 22),
            _ScoreCard(result: result, accuracy: accuracy),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_outline_rounded,
                    value: '${result.correctAnswers}',
                    label: 'Correct',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.cancel_outlined,
                    value: '${result.wrongAnswers}',
                    label: 'Wrong',
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.help_outline_rounded,
                    value: '${result.unanswered}',
                    label: 'Skipped',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const SectionTitle(
              title: 'Performance Summary',
              subtitle: 'A breakdown of your practice session',
            ),
            const SizedBox(height: 12),
            _SummaryCard(result: result),
            const SizedBox(height: 26),
            _Insight(accuracy: accuracy),
            const SizedBox(height: 26),
            GradientButton(
              label: 'Review Answers',
              icon: Icons.fact_check_outlined,
              onTap:
                  () => context.pushNamed(
                    'solution',
                    pathParameters: {'examId': examId, 'attemptId': attemptId},
                  ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ref.invalidate(quizControllerProvider);
                context.pushReplacementNamed(
                  'quiz',
                  pathParameters: {'examId': examId},
                );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Practice Again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: const Size.fromHeight(54),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// HEADER
// =============================================================================

class _Header extends StatelessWidget {
  final int accuracy;

  const _Header({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = _ResultPresentation.from(accuracy);

    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: p.color.withValues(alpha: .10),
            shape: BoxShape.circle,
          ),
          child: Icon(p.icon, size: 50, color: p.color),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        Text(
          p.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: .1, end: 0),
        const SizedBox(height: 6),
        Text(
          'You completed',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 3),
        Text(
          'Practice Session',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(delay: 250.ms),
      ],
    );
  }
}

// =============================================================================
// SCORE CARD
// =============================================================================

class _ScoreCard extends StatelessWidget {
  final QuizResult result;
  final int accuracy;

  const _ScoreCard({required this.result, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final progress = (accuracy / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.pink, AppColors.purple],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: .18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Your Score',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder:
                      (_, v, _) => SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: v,
                          strokeWidth: 13,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.white.withValues(alpha: .22),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: accuracy),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder:
                          (_, v, _) => Text(
                            '$v%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                    ),
                    Text(
                      '${result.correctAnswers}/${result.totalQuestions}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: .08, end: 0);
  }
}

// =============================================================================
// STAT CARD
// =============================================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .5),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .09),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUMMARY CARD
// =============================================================================

class _SummaryCard extends StatelessWidget {
  final QuizResult result;

  const _SummaryCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avg =
        result.totalQuestions == 0
            ? 0
            : (result.timeSpent.inSeconds / result.totalQuestions).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .5),
        ),
      ),
      child: Column(
        children: [
          _Row(
            icon: Icons.quiz_outlined,
            label: 'Total Questions',
            value: '${result.totalQuestions}',
          ),
          _Div(color: theme.colorScheme.outlineVariant),
          _Row(
            icon: Icons.check_circle_outline_rounded,
            label: 'Correct Answers',
            value: '${result.correctAnswers}',
            color: AppColors.success,
          ),
          _Div(color: theme.colorScheme.outlineVariant),
          _Row(
            icon: Icons.cancel_outlined,
            label: 'Wrong Answers',
            value: '${result.wrongAnswers}',
            color: Colors.redAccent,
          ),
          _Div(color: theme.colorScheme.outlineVariant),
          _Row(
            icon: Icons.help_outline_rounded,
            label: 'Unanswered',
            value: '${result.unanswered}',
          ),
          _Div(color: theme.colorScheme.outlineVariant),
          _Row(
            icon: Icons.schedule_rounded,
            label: 'Time Taken',
            value: _formatDuration(result.timeSpent),
          ),
          _Div(color: theme.colorScheme.outlineVariant),
          _Row(
            icon: Icons.speed_rounded,
            label: 'Average per Question',
            value: '${avg}s',
          ),
          _Div(color: theme.colorScheme.outlineVariant),
          _Row(
            icon: Icons.stars_rounded,
            label: 'Points Earned',
            value: '+${result.correctAnswers * 10}',
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }
}

// =============================================================================
// ROW
// =============================================================================

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Div extends StatelessWidget {
  final Color color;

  const _Div({required this.color});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: color.withValues(alpha: .4));
  }
}

// =============================================================================
// INSIGHT
// =============================================================================

class _Insight extends StatelessWidget {
  final int accuracy;

  const _Insight({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = _ResultPresentation.from(accuracy);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.color.withValues(alpha: .15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.color.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: p.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Insight',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  p.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PRESENTATION LOGIC
// =============================================================================

class _ResultPresentation {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const _ResultPresentation({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  factory _ResultPresentation.from(int score) {
    if (score >= 80) {
      return const _ResultPresentation(
        title: 'Excellent!',
        message:
            'Excellent work. You have a strong understanding of this topic. '
            'Review the questions you missed and keep practising.',
        icon: Icons.emoji_events_rounded,
        color: AppColors.warning,
      );
    }
    if (score >= 70) {
      return const _ResultPresentation(
        title: 'Great Job!',
        message:
            'You performed well. Review your incorrect answers and practise '
            'the topics that gave you difficulty.',
        icon: Icons.workspace_premium_rounded,
        color: AppColors.purple,
      );
    }
    if (score >= 50) {
      return const _ResultPresentation(
        title: 'Good Effort!',
        message:
            'You are making progress. Review the explanations for your '
            'incorrect answers and practise these topics again.',
        icon: Icons.trending_up_rounded,
        color: Colors.orange,
      );
    }
    return const _ResultPresentation(
      title: 'Keep Practising',
      message:
          'Review the solutions carefully and focus on the topics where you '
          'had difficulty before attempting another practice session.',
      icon: Icons.school_outlined,
      color: Colors.redAccent,
    );
  }
}
