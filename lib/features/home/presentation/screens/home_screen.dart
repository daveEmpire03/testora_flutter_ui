import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:testora_flutter_ui/shared/testora_widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_providers.dart';

// =============================================================================
// HOME
// =============================================================================

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.firstName ?? 'Student',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    (user?.firstName.isNotEmpty ?? false)
                        ? user!.firstName[0].toUpperCase()
                        : 'S',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.pink, AppColors.purple],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ready to practice?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pick a subject and continue learning.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  GradientButton(
                    label: 'Start Practice',
                    onTap: () => context.go('/exams'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const SectionTitle(
              title: 'Quick Access',
              subtitle: 'Jump straight into a session',
            ),
            const SizedBox(height: 14),
            _Tile(
              icon: Icons.menu_book_outlined,
              title: 'All Subjects',
              subtitle: 'Browse every exam subject',
              onTap: () => context.go('/exams'),
            ),
            const SizedBox(height: 10),
            _Tile(
              icon: Icons.timer_outlined,
              title: 'Mock Exams',
              subtitle: 'Full-length timed practice',
              onTap: () => context.push('/mock-exams'),
            ),
            const SizedBox(height: 10),
            _Tile(
              icon: Icons.bar_chart_outlined,
              title: 'My Progress',
              subtitle: 'See your performance',
              onTap: () => context.go('/progress'),
            ),
          ],
        ),
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
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CATEGORIES (stub — referenced by router)
// =============================================================================

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
