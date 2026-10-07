import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/testora_widgets.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../exams/application/exam_catalog_providers.dart';
import '../../../exams/domain/entities/exam_category.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final categories = ref.watch(examCategoriesProvider);
    final tokens = context.tokens;
    final firstName =
        (auth.user?.firstName.trim().isNotEmpty ?? false)
            ? auth.user!.firstName.trim()
            : 'Student';

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
                _HomeHeader(firstName: firstName),
                const SizedBox(height: AppSpacing.section),
                const SectionTitle(
                  title: 'Available examinations',
                  subtitle: 'Choose the exam you want to prepare for',
                ),
                const SizedBox(height: AppSpacing.md),
              ]),
            ),
          ),
          categories.when(
            loading:
                () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: TestoraLoading(message: 'Loading examinations...'),
                  ),
                ),
            error:
                (error, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: TestoraEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Could not load examinations',
                      message: '$error',
                    ),
                  ),
                ),
            data:
                (items) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = items[index];
                        return _ExamTypeCard(
                              category: category,
                              onTap: () {
                                ref
                                    .read(
                                      selectedExamCategoryProvider.notifier,
                                    )
                                    .select(category.id);
                                context.go('/exams');
                              },
                            )
                            .animate(delay: (45 * index).ms)
                            .fadeIn(duration: 240.ms)
                            .slideY(
                              begin: 0.04,
                              end: 0,
                              duration: 240.ms,
                              curve: Curves.easeOutCubic,
                            );
                      },
                      childCount: items.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: 1.02,
                        ),
                  ),
                ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.section,
              AppSpacing.lg,
              AppSpacing.sp40,
            ),
            sliver: SliverToBoxAdapter(
              child: TestoraCard(
                onTap: () => context.go('/progress'),
                backgroundColor: tokens.surfaceSecondary,
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: tokens.textPrimary,
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                      child: Icon(
                        Icons.insights_outlined,
                        color: tokens.background,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Track your progress',
                            style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'See your performance across practice sessions.',
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: tokens.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 26,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _HeaderButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => context.push('/profile/notifications'),
        ),
        const SizedBox(width: AppSpacing.sm),
        _ProfileAvatar(name: firstName),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onTap});

  final IconData icon;
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
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: tokens.border),
          ),
          child: Icon(icon, size: 21, color: tokens.textPrimary),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/profile'),
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tokens.textPrimary,
            border: Border.all(color: tokens.cardBorder),
          ),
          child: Text(
            (name.isNotEmpty ? name[0] : 'S').toUpperCase(),
            style: TextStyle(
              color: tokens.background,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamTypeCard extends StatelessWidget {
  const _ExamTypeCard({
    required this.category,
    required this.onTap,
  });

  final ExamCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: tokens.border),
            ),
            child: Text(
              category.shortCode,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TestoraEmptyState(
        icon: Icons.category_outlined,
        title: 'Categories',
        message: 'Browse exam categories here.',
      ),
    );
  }
}
