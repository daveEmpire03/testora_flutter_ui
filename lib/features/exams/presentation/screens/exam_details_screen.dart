import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:testora_flutter_ui/shared/testora_widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../quiz/providers/quiz_providers.dart';

class ExamDetailsScreen extends ConsumerWidget {
  final String examId;

  const ExamDetailsScreen({super.key, required this.examId});

  String get _name {
    if (examId.isEmpty) return 'Subject';
    return examId[0].toUpperCase() + examId.substring(1);
  }

  void _startQuiz(BuildContext context, WidgetRef ref) {
    // Reset any previous attempt state so a fresh quiz starts.
    ref.invalidate(quizControllerProvider);
    context.pushNamed('quiz', pathParameters: {'examId': examId});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
        children: [
          // Hero
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.pink, AppColors.purple],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: .16),
                  blurRadius: 22,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.functions_rounded,
                    size: 42,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  '$_name Practice',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'UTME / JAMB Past Questions',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 13),
                const Text(
                  'Build your confidence with past questions, '
                  'topic-based practice and timed mock exams.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Primary actions
          GradientButton(
            label: 'Start Practice',
            icon: Icons.play_arrow_rounded,
            onTap: () => _startQuiz(context, ref),
          ),
          const SizedBox(height: 11),
          OutlinedButton.icon(
            onPressed: () => context.push('/mock-exams'),
            icon: const Icon(Icons.timer_outlined),
            label: const Text('Take Mock Exam'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Study options
          const SectionTitle(
            title: 'Study & Practice',
            subtitle: 'Choose how you want to prepare',
          ),
          const SizedBox(height: 13),
          _Tile(
            icon: Icons.bolt_rounded,
            title: 'Quick Practice',
            subtitle: '10 random questions',
            badge: 'Fast',
            onTap: () => _startQuiz(context, ref),
          ),
          const SizedBox(height: 10),
          _Tile(
            icon: Icons.quiz_outlined,
            title: 'Standard Practice',
            subtitle: '20 random questions',
            badge: '20 Qs',
            onTap: () => _startQuiz(context, ref),
          ),
          const SizedBox(height: 10),
          _Tile(
            icon: Icons.topic_outlined,
            title: 'Practice by Topic',
            subtitle: 'Focus on a specific topic',
            badge: 'Topics',
            onTap: () => _startQuiz(context, ref),
          ),
          const SizedBox(height: 10),
          _Tile(
            icon: Icons.calendar_month_outlined,
            title: 'Past Questions by Year',
            subtitle: 'Practise previous UTME questions',
            badge: '15 years',
            onTap: () => _startQuiz(context, ref),
          ),
          const SizedBox(height: 10),
          _Tile(
            icon: Icons.timer_outlined,
            title: 'Mock Examination',
            subtitle: 'Practise under timed conditions',
            badge: 'Timed',
            onTap: () => context.push('/mock-exams'),
          ),

          const SizedBox(height: 30),

          // Insight
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: .12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: .10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    color: theme.colorScheme.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Study Insight',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Consistent daily practice is the fastest way to '
                        'improve your scores. Aim for at least 20 questions '
                        'per day.',
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
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TILE
// =============================================================================

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: .5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
              ],
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
