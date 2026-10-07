import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      body: navigationShell,
      bottomNavigationBar: _TestoraBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onDestinationSelected,
      ),
    );
  }
}

// =============================================================================
// COMPACT ELEVATED BOTTOM NAVIGATION
// =============================================================================

class _TestoraBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TestoraBottomNav({required this.currentIndex, required this.onTap});

  static const _items = <_NavItem>[
    _NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavItem(
      label: 'Exams',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
    ),
    _NavItem(
      label: 'Progress',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? tokens.surface : tokens.surface,
        border: Border(top: BorderSide(color: tokens.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isSelected = i == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  splashColor: tokens.textPrimary.withValues(alpha: 0.04),
                  highlightColor: Colors.transparent,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            width: isSelected ? 40 : 36,
                            height: 28,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? (isDark
                                          ? tokens.surfaceSecondary
                                          : tokens.surfaceSecondary)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border:
                                  isSelected
                                      ? Border.all(
                                        color: tokens.cardBorder,
                                        width: 1,
                                      )
                                      : null,
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              size: 20,
                              color:
                                  isSelected
                                      ? tokens.textPrimary
                                      : tokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                              color:
                                  isSelected
                                      ? tokens.textPrimary
                                      : tokens.textSecondary,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
