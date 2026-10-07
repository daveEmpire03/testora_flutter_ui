import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:testora_flutter_ui/shared/testora_widgets.dart';

import '../../../auth/providers/auth_providers.dart';

// =============================================================================
// PROFILE
// =============================================================================

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          // Avatar + name
          Column(
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  (user?.firstName.isNotEmpty ?? false)
                      ? user!.firstName[0].toUpperCase()
                      : 'S',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                user?.fullName ?? 'Student',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (user != null) ...[
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 30),

          // Menu
          _Tile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () => context.pushNamed('settings'),
          ),
          const SizedBox(height: 8),
          _Tile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            onTap: () => context.pushNamed('notifications'),
          ),
          const SizedBox(height: 8),
          _Tile(
            icon: Icons.emoji_events_outlined,
            title: 'Achievements',
            onTap: () => context.pushNamed('achievements'),
          ),
          const SizedBox(height: 8),
          _Tile(
            icon: Icons.history_rounded,
            title: 'History',
            onTap: () => context.pushNamed('history'),
          ),
          const SizedBox(height: 8),
          _Tile(
            icon: Icons.bookmark_border_rounded,
            title: 'Bookmarks',
            onTap: () => context.pushNamed('bookmarks'),
          ),

          const SizedBox(height: 30),

          // Logout
          OutlinedButton.icon(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: BorderSide(color: Colors.redAccent.withValues(alpha: .3)),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MENU TILE
// =============================================================================

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _Tile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: .5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
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
// STUB SCREENS
// =============================================================================

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const TestoraEmptyState(
        icon: Icons.settings_outlined,
        title: 'Settings',
        message: 'App settings will appear here.',
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
