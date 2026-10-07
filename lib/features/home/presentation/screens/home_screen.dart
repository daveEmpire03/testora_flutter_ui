import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../../shared/testora_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final tokens = context.tokens;
    final firstName =
        (user?.firstName.trim().isNotEmpty ?? false)
            ? user!.firstName.trim()
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
                const SizedBox(height: AppSpacing.xxl),
                _PracticeHero(
                  onStart: () => context.go('/exams'),
                ).animate().fadeIn(duration: 320.ms).slideY(
                  begin: 0.04,
                  end: 0,
                  duration: 320.ms,
                  curve: Curves.easeOutCubic,
                ),
                const SizedBox(height: AppSpacing.section),
                SectionTitle(
                  title: 'Practice',
                  subtitle: 'Choose how you want to study',
                  actionLabel: 'View exams',
                  onActionPressed: () => context.go('/exams'),
                ),
                const SizedBox(height: AppSpacing.md),
                _PracticeGrid(
                  onSubjects: () => context.go('/exams'),
                  onMockExam: () => context.push('/mock-exams'),
                  onBookmarks: () => context.push('/profile/bookmarks'),
                  onProgress: () => context.go('/progress'),
                ),
                const SizedBox(height: AppSpacing.section),
                const SectionTitle(
                  title: 'Study smarter',
                  subtitle: 'Useful shortcuts for your next session',
                ),
                const SizedBox(height: AppSpacing.md),
                _StudyToolCard(
                  icon: Icons.history_rounded,
                  title: 'Practice history',
                  subtitle: 'Review your previous study sessions and attempts.',
                  onTap: () => context.push('/profile/history'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _StudyToolCard(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Achievements',
                  subtitle: 'See milestones you have reached while studying.',
                  onTap: () => context.push('/profile/achievements'),
                ),
              ]),
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
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          semanticLabel: 'Notifications',
          onTap: () => context.push('/profile/notifications'),
        ),
        const SizedBox(width: AppSpacing.sm),
        _ProfileAvatar(name: firstName),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
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
            name.characters.first.toUpperCase(),
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

class _PracticeHero extends StatelessWidget {
  const _PracticeHero({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: tokens.textPrimary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -28,
            child: IgnorePointer(
              child: Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tokens.background.withValues(alpha: 0.10),
                    width: 18,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -50,
            child: IgnorePointer(
              child: Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.background.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tokens.background.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.school_outlined,
                  color: tokens.background,
                  size: 22,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Ready for your next\npractice session?',
                style: TextStyle(
                  color: tokens.background,
                  fontSize: 22,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choose an exam, practise at your pace, and review every answer.',
                style: TextStyle(
                  color: tokens.background.withValues(alpha: 0.72),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: tokens.background,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  child: InkWell(
                    onTap: onStart,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Start practice',
                            style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: tokens.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PracticeGrid extends StatelessWidget {
  const _PracticeGrid({
    required this.onSubjects,
    required this.onMockExam,
    required this.onBookmarks,
    required this.onProgress,
  });

  final VoidCallback onSubjects;
  final VoidCallback onMockExam;
  final VoidCallback onBookmarks;
  final VoidCallback onProgress;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      TestoraGridCard(
        icon: Icons.menu_book_outlined,
        title: 'Subjects',
        subtitle: 'Browse all exams',
        onTap: onSubjects,
      ),
      TestoraGridCard(
        icon: Icons.timer_outlined,
        title: 'Mock exam',
        subtitle: 'Timed CBT practice',
        onTap: onMockExam,
      ),
      TestoraGridCard(
        icon: Icons.bookmark_border_rounded,
        title: 'Bookmarks',
        subtitle: 'Saved questions',
        onTap: onBookmarks,
      ),
      TestoraGridCard(
        icon: Icons.insights_outlined,
        title: 'Progress',
        subtitle: 'Track performance',
        onTap: onProgress,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AppSpacing.md;
        final itemWidth = (constraints.maxWidth - gap) / 2;
        final itemHeight = itemWidth.clamp(142.0, 176.0);

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < cards.length; i++)
              SizedBox(
                    width: itemWidth,
                    height: itemHeight,
                    child: cards[i],
                  )
                  .animate(delay: (60 * i).ms)
                  .fadeIn(duration: 260.ms)
                  .slideY(
                    begin: 0.05,
                    end: 0,
                    duration: 260.ms,
                    curve: Curves.easeOutCubic,
                  ),
          ],
        );
      },
    );
  }
}

class _StudyToolCard extends StatelessWidget {
  const _StudyToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
              borderRadius: BorderRadius.circular(AppRadius.md),
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
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: tokens.textSecondary,
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
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: const TestoraEmptyState(
        icon: Icons.category_outlined,
        title: 'Categories',
        message: 'Browse exam categories here.',
      ),
    );
  }
}
