import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/testora_widgets.dart';
import '../../../auth/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final tokens = context.tokens;
    final fullName =
        (user?.fullName.trim().isNotEmpty ?? false)
            ? user!.fullName.trim()
            : 'Student';
    final firstLetter =
        fullName.isNotEmpty ? fullName[0].toUpperCase() : 'S';

    return TestoraScaffold(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.sp40,
        ),
        children: [
          Text(
            'Profile',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 28,
              height: 1.05,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _ProfileIdentityCard(
            name: fullName,
            email: user?.email,
            initial: firstLetter,
          ),
          const SizedBox(height: AppSpacing.section),
          const SectionTitle(title: 'Account'),
          const SizedBox(height: AppSpacing.md),
          _MenuGroup(
            items: [
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'Appearance and app preferences',
                onTap: () => context.pushNamed('settings'),
              ),
              _ProfileMenuItem(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Updates and reminders',
                onTap: () => context.pushNamed('notifications'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          const SectionTitle(title: 'Learning'),
          const SizedBox(height: AppSpacing.md),
          _MenuGroup(
            items: [
              _ProfileMenuItem(
                icon: Icons.workspace_premium_outlined,
                title: 'Achievements',
                subtitle: 'Milestones from your study activity',
                onTap: () => context.pushNamed('achievements'),
              ),
              _ProfileMenuItem(
                icon: Icons.history_rounded,
                title: 'History',
                subtitle: 'Previous quizzes and exam attempts',
                onTap: () => context.pushNamed('history'),
              ),
              _ProfileMenuItem(
                icon: Icons.bookmark_border_rounded,
                title: 'Bookmarks',
                subtitle: 'Questions you saved for later',
                onTap: () => context.pushNamed('bookmarks'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          TestoraButton(
            label: 'Sign out',
            icon: Icons.logout_rounded,
            variant: TestoraButtonVariant.outlined,
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout_rounded, size: 32),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Sign out of Testora?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'You can sign back in whenever you are ready to continue studying.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TestoraButton(
                  label: 'Sign out',
                  onTap: () => Navigator.of(sheetContext).pop(true),
                ),
                const SizedBox(height: AppSpacing.sm),
                TestoraButton(
                  label: 'Cancel',
                  variant: TestoraButtonVariant.ghost,
                  onTap: () => Navigator.of(sheetContext).pop(false),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      ref.read(authProvider.notifier).logout();
    }
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard({
    required this.name,
    required this.email,
    required this.initial,
  });

  final String name;
  final String? email;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.textPrimary,
            ),
            child: Text(
              initial,
              style: TextStyle(
                color: tokens.background,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (email != null && email!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    email!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});

  final List<_ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: tokens.cardBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i != items.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 68),
                child: Divider(color: tokens.divider),
              ),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: tokens.border),
                ),
                child: Icon(icon, color: tokens.textPrimary, size: 20),
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 11.5,
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
        ),
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.sp40,
        ),
        children: [
          const SectionTitle(
            title: 'Appearance',
            subtitle: 'Choose how Testora looks on this device',
          ),
          const SizedBox(height: AppSpacing.md),
          _ThemeOption(
            icon: Icons.brightness_auto_outlined,
            title: 'System',
            subtitle: 'Follow your device appearance',
            selected: selectedMode == ThemeMode.system,
            onTap:
                () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.system),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ThemeOption(
            icon: Icons.light_mode_outlined,
            title: 'Light',
            subtitle: 'Always use the light theme',
            selected: selectedMode == ThemeMode.light,
            onTap:
                () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.light),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ThemeOption(
            icon: Icons.dark_mode_outlined,
            title: 'Dark',
            subtitle: 'Always use the dark theme',
            selected: selectedMode == ThemeMode.dark,
            onTap:
                () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraCard(
      onTap: onTap,
      isSelected: selected,
      child: Row(
        children: [
          Icon(icon, color: tokens.textPrimary, size: 22),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? tokens.textPrimary : Colors.transparent,
              border: Border.all(
                color: selected ? tokens.textPrimary : tokens.border,
                width: 1.5,
              ),
            ),
            child:
                selected
                    ? Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: tokens.background,
                    )
                    : null,
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const TestoraEmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications',
        message: 'You are all caught up.',
      ),
    );
  }
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: const TestoraEmptyState(
        icon: Icons.emoji_events_outlined,
        title: 'Achievements',
        message: 'Complete quizzes to unlock achievements.',
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const TestoraEmptyState(
        icon: Icons.history_rounded,
        title: 'No history',
        message: 'Your past quiz attempts will appear here.',
      ),
    );
  }
}
