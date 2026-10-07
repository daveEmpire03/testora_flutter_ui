import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testora_flutter_ui/shared/testora_widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../providers/progress_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(progressStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        actions: [
          IconButton(
            tooltip: 'Progress information',
            onPressed: () => _showInfo(context),
            icon: const Icon(Icons.info_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: stats.when(
        loading: () => const TestoraListSkeleton(itemHeight: 110),
        error:
            (e, _) => TestoraEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Could not load progress',
              message: e.toString(),
              actionLabel: 'Retry',
              onAction: () => ref.invalidate(progressStatsProvider),
            ),
        data: (data) => _Body(stats: data),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder:
          (context) => const Padding(
            padding: EdgeInsets.fromLTRB(24, 4, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About your progress',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 10),
                Text(
                  'Your Testora progress is calculated from the questions you '
                  'answer during practice sessions and mock exams. Continue '
                  'practising to improve your subject performance.',
                  style: TextStyle(height: 1.5, color: Colors.black54),
                ),
              ],
            ),
          ),
    );
  }
}

// =============================================================================
// BODY
// =============================================================================

class _Body extends StatelessWidget {
  final ProgressStats stats;

  const _Body({required this.stats});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
      children: [
        _OverallCard(percentage: stats.overallAccuracy),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _Stat(
                value: '${stats.totalQuestions}',
                label: 'Questions',
                icon: Icons.quiz_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Stat(
                value: '${stats.correctAnswers}',
                label: 'Correct',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Stat(
                value: '${stats.wrongAnswers}',
                label: 'Wrong',
                icon: Icons.cancel_outlined,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const SectionTitle(
          title: 'Study Activity',
          subtitle: 'Questions answered this week',
        ),
        const SizedBox(height: 14),
        _ActivityCard(activity: stats.weeklyActivity),
        const SizedBox(height: 30),
        const SectionTitle(
          title: 'Subject Performance',
          subtitle: 'Your performance across subjects',
        ),
        const SizedBox(height: 14),
        _SubjectList(subjects: stats.subjects),
        const SizedBox(height: 30),
        _Streak(streak: stats.studyStreak),
      ],
    );
  }
}

// =============================================================================
// OVERALL CARD
// =============================================================================

class _OverallCard extends StatelessWidget {
  final double percentage;

  const _OverallCard({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final pct = (percentage * 100).round();

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
            'Overall Performance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percentage),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder:
                      (_, v, _) => SizedBox(
                        width: 150,
                        height: 150,
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
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: pct),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder:
                      (_, v, _) => Text(
                        '$v%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: .06, end: 0);
  }
}

// =============================================================================
// STAT
// =============================================================================

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? color;

  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;

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
          Icon(icon, size: 22, color: accent),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: accent,
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
// ACTIVITY CARD
// =============================================================================

class _ActivityCard extends StatelessWidget {
  final List<DayActivity> activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < activity.length; i++)
            Expanded(child: _Bar(data: activity[i], delay: i * 60)),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final DayActivity data;
  final int delay;

  const _Bar({required this.data, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: data.value.clamp(0.0, 1.0),
                  child: Container(
                    width: 16,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.purple, AppColors.pink],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data.day,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        )
        .animate(delay: delay.ms)
        .fadeIn(duration: 250.ms)
        .scaleY(begin: .1, end: 1, alignment: Alignment.bottomCenter);
  }
}

// =============================================================================
// SUBJECT LIST
// =============================================================================

class _SubjectList extends StatelessWidget {
  final List<SubjectPerformance> subjects;

  const _SubjectList({required this.subjects});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .5),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < subjects.length; i++) ...[
            _SubjectTile(subject: subjects[i]),
            if (i != subjects.length - 1)
              Divider(
                height: 1,
                indent: 74,
                color: theme.colorScheme.outlineVariant.withValues(alpha: .4),
              ),
          ],
        ],
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final SubjectPerformance subject;

  const _SubjectTile({required this.subject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (subject.score * 100).round();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              subject.icon,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subject.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$pct%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: subject.score),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder:
                        (_, v, _) => LinearProgressIndicator(
                          value: v,
                          minHeight: 7,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          color: theme.colorScheme.primary,
                        ),
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
// STREAK
// =============================================================================

class _Streak extends StatelessWidget {
  final int streak;

  const _Streak({required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 38)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak Day Study Streak',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Keep practising every day to maintain your streak.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: .05, end: 0);
  }
}
