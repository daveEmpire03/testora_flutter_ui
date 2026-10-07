import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/testora_widgets.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  static const _subjects = [
    _Subject(
      id: 'mathematics',
      name: 'Mathematics',
      description: 'Numbers & problem solving',
      icon: Icons.functions_rounded,
    ),
    _Subject(
      id: 'english',
      name: 'English Language',
      description: 'Grammar & comprehension',
      icon: Icons.translate_rounded,
    ),
    _Subject(
      id: 'physics',
      name: 'Physics',
      description: 'Motion, energy & matter',
      icon: Icons.science_outlined,
    ),
    _Subject(
      id: 'chemistry',
      name: 'Chemistry',
      description: 'Matter & reactions',
      icon: Icons.biotech_outlined,
    ),
    _Subject(
      id: 'biology',
      name: 'Biology',
      description: 'Life & living systems',
      icon: Icons.eco_outlined,
    ),
    _Subject(
      id: 'government',
      name: 'Government',
      description: 'Civics & political systems',
      icon: Icons.gavel_rounded,
    ),
    _Subject(
      id: 'economics',
      name: 'Economics',
      description: 'Markets & resources',
      icon: Icons.trending_up_rounded,
    ),
    _Subject(
      id: 'literature',
      name: 'Literature',
      description: 'Texts & interpretation',
      icon: Icons.menu_book_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.sp40,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subjects',
                            style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 28,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Pick a subject and practise exam-style questions.',
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _MockExamButton(
                      onTap: () => context.push('/mock-exams'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                _ExamDiscoveryBanner(
                  onTap: () => context.push('/mock-exams'),
                ),
                const SizedBox(height: AppSpacing.section),
                const SectionTitle(
                  title: 'All subjects',
                  subtitle: 'Choose what you want to practise',
                ),
                const SizedBox(height: AppSpacing.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final gap = AppSpacing.md;
                    final width = (constraints.maxWidth - gap) / 2;
                    final height = width.clamp(150.0, 182.0).toDouble();

                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (var i = 0; i < _subjects.length; i++)
                          SizedBox(
                                width: width,
                                height: height,
                                child: TestoraGridCard(
                                  icon: _subjects[i].icon,
                                  title: _subjects[i].name,
                                  subtitle: _subjects[i].description,
                                  onTap:
                                      () => context.pushNamed(
                                        'exam-details',
                                        pathParameters: {
                                          'examId': _subjects[i].id,
                                        },
                                      ),
                                ),
                              )
                              .animate(delay: (45 * i).ms)
                              .fadeIn(duration: 240.ms)
                              .slideY(
                                begin: 0.04,
                                end: 0,
                                duration: 240.ms,
                                curve: Curves.easeOutCubic,
                              ),
                      ],
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockExamButton extends StatelessWidget {
  const _MockExamButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Material(
      color: tokens.surfaceSecondary,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: tokens.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: tokens.textPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Mock',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamDiscoveryBanner extends StatelessWidget {
  const _ExamDiscoveryBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: tokens.surfaceSecondary,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.textPrimary,
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Icon(
              Icons.assignment_turned_in_outlined,
              color: tokens.background,
              size: 23,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Take a full mock exam',
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Practise under timed CBT conditions.',
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.arrow_forward_rounded,
            color: tokens.textPrimary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _Subject {
  const _Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
}
