import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/testora_widgets.dart';
import '../../application/exam_catalog_providers.dart';
import '../../../quiz/application/quiz_setup_provider.dart';

class ExamDetailsScreen extends ConsumerWidget {
  const ExamDetailsScreen({super.key, required this.examId});

  final String examId;

  String get _name {
    if (examId.isEmpty) return 'Subject';
    if (examId == 'english') return 'English Language';
    return examId[0].toUpperCase() + examId.substring(1);
  }

  IconData get _icon {
    switch (examId) {
      case 'mathematics':
        return Icons.functions_rounded;
      case 'english':
        return Icons.translate_rounded;
      case 'physics':
        return Icons.science_outlined;
      case 'chemistry':
        return Icons.biotech_outlined;
      case 'biology':
        return Icons.eco_outlined;
      case 'government':
        return Icons.gavel_rounded;
      case 'economics':
        return Icons.trending_up_rounded;
      case 'literature':
        return Icons.menu_book_rounded;
      default:
        return Icons.school_outlined;
    }
  }

  void _startQuiz(BuildContext context, WidgetRef ref) {
    final categoryId = ref.read(selectedExamCategoryProvider);

    ref
        .read(quizSetupProvider.notifier)
        .resetForExam(categoryId, subjectId: examId);

    context.pushNamed(
      'quiz-setup',
      pathParameters: {'examId': examId},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: Text(_name)),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.sp40,
        ),
        children: [
          _SubjectHero(
            icon: _icon,
            subject: _name,
            onStart: () => _startQuiz(context, ref),
          ),
          const SizedBox(height: AppSpacing.section),
          const SectionTitle(
            title: 'Study & practice',
            subtitle: 'Choose the session that fits your goal',
          ),
          const SizedBox(height: AppSpacing.md),
          _PracticeOption(
            icon: Icons.bolt_rounded,
            title: 'Quick practice',
            subtitle: 'A short set of random questions',
            badge: '10 Qs',
            onTap: () => _startQuiz(context, ref),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PracticeOption(
            icon: Icons.quiz_outlined,
            title: 'Standard practice',
            subtitle: 'Build consistency with a longer session',
            badge: '20 Qs',
            onTap: () => _startQuiz(context, ref),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PracticeOption(
            icon: Icons.topic_outlined,
            title: 'Practice by topic',
            subtitle: 'Focus on a specific area of the subject',
            badge: 'Topics',
            onTap: () => _startQuiz(context, ref),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PracticeOption(
            icon: Icons.calendar_month_outlined,
            title: 'Past questions',
            subtitle: 'Work through previous exam questions',
            badge: 'Years',
            onTap: () => _startQuiz(context, ref),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PracticeOption(
            icon: Icons.timer_outlined,
            title: 'Mock examination',
            subtitle: 'Practise under timed CBT conditions',
            badge: 'Timed',
            onTap: () => _startQuiz(context, ref),
          ),
          const SizedBox(height: AppSpacing.section),
          TestoraCard(
            backgroundColor: tokens.surfaceSecondary,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: tokens.card,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: tokens.border),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    color: tokens.textPrimary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Study tip',
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Practise consistently, then review the explanations for questions you miss before starting another session.',
                        style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 12,
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

class _SubjectHero extends StatelessWidget {
  const _SubjectHero({
    required this.icon,
    required this.subject,
    required this.onStart,
  });

  final IconData icon;
  final String subject;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      backgroundColor: tokens.surfaceSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: tokens.textPrimary,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Icon(icon, color: tokens.background, size: 29),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '$subject practice',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 24,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Prepare with exam-style questions, focused practice and timed sessions.',
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TestoraButton(
            label: 'Start practice',
            icon: Icons.play_arrow_rounded,
            onTap: onStart,
          ),
        ],
      ),
    );
  }
}

class _PracticeOption extends StatelessWidget {
  const _PracticeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: tokens.border),
            ),
            child: Icon(icon, size: 21, color: tokens.textPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TestoraBadge(label: badge),
        ],
      ),
    );
  }
}
