import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
export 'testora_forms.dart';

// =============================================================================
// TESTORA SCAFFOLD
// =============================================================================

class TestoraScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool safeArea;

  const TestoraScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: backgroundColor ?? tokens.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: safeArea ? SafeArea(child: child) : child,
    );
  }
}

/// Backward-compatible adapter for legacy GradientScaffold usages.
class GradientScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;
  final bool safeArea;

  const GradientScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return TestoraScaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      safeArea: safeArea,
      child: child,
    );
  }
}

// =============================================================================
// TESTORA CARD
// =============================================================================

class TestoraCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const TestoraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.borderRadius = AppRadius.card,
    this.backgroundColor,
    this.borderColor,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final effectiveBorder =
        isSelected
            ? Border.all(color: tokens.textPrimary, width: 1.5)
            : Border.all(color: borderColor ?? tokens.cardBorder, width: 1);

    final cardContent = Container(
      width: double.infinity,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isSelected ? tokens.surfaceSecondary : tokens.card),
        borderRadius: BorderRadius.circular(borderRadius),
        border: effectiveBorder,
      ),
      child: child,
    );

    if (onTap == null) return cardContent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: tokens.textPrimary.withValues(alpha: 0.05),
        highlightColor: tokens.textPrimary.withValues(alpha: 0.03),
        child: cardContent,
      ),
    );
  }
}

/// Backward-compatible adapter for legacy GlassCard usages.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.borderRadius = AppRadius.card,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TestoraCard(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      child: child,
    );
  }
}

// =============================================================================
// TESTORA GRID CARD (Two-Column Discovery Card)
// =============================================================================

class TestoraGridCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final Widget? badge;
  final bool isSelected;
  final VoidCallback? onTap;

  const TestoraGridCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.badge,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraCard(
      isSelected: isSelected,
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading ??
                  (icon != null
                      ? Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? tokens.textPrimary
                                  : tokens.surfaceSecondary,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: tokens.border, width: 1),
                        ),
                        child: Icon(
                          icon,
                          size: 22,
                          color:
                              isSelected
                                  ? tokens.background
                                  : tokens.textPrimary,
                        ),
                      )
                      : const SizedBox.shrink()),
              if (badge != null) badge! else if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TESTORA BUTTON
// =============================================================================

enum TestoraButtonVariant { primary, secondary, outlined, ghost }

class TestoraButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final TestoraButtonVariant variant;
  final double height;
  final double borderRadius;
  final double? width;

  const TestoraButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.leading,
    this.trailing,
    this.variant = TestoraButtonVariant.primary,
    this.height = 50,
    this.borderRadius = AppRadius.button,
    this.width,
  });

  bool get _canPress => enabled && !isLoading && onTap != null;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case TestoraButtonVariant.primary:
        bg = isDark ? AppColors.primaryDark : AppColors.primaryLight;
        fg = isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight;
      case TestoraButtonVariant.secondary:
        bg = tokens.surfaceSecondary;
        fg = tokens.textPrimary;
        borderSide = BorderSide(color: tokens.border, width: 1);
      case TestoraButtonVariant.outlined:
        bg = Colors.transparent;
        fg = tokens.textPrimary;
        borderSide = BorderSide(color: tokens.border, width: 1);
      case TestoraButtonVariant.ghost:
        bg = Colors.transparent;
        fg = tokens.textPrimary;
    }

    if (!enabled) {
      bg = bg.withValues(alpha: 0.35);
      fg = fg.withValues(alpha: 0.45);
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: _canPress ? 1.0 : 0.6,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide,
          ),
          child: InkWell(
            onTap: _canPress ? onTap : null,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child:
                    isLoading
                        ? SizedBox(
                          key: const ValueKey('loader'),
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: fg,
                          ),
                        )
                        : Row(
                          key: const ValueKey('content'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (leading != null) ...[
                              leading!,
                              const SizedBox(width: AppSpacing.sm),
                            ] else if (icon != null) ...[
                              Icon(icon, color: fg, size: 19),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                            Text(
                              label,
                              style: TextStyle(
                                color: fg,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 0.1,
                              ),
                            ),
                            if (trailing != null) ...[
                              const SizedBox(width: AppSpacing.sm),
                              trailing!,
                            ],
                          ],
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Backward-compatible adapter for legacy GradientButton usages.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final double height;
  final double borderRadius;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.height = 50,
    this.borderRadius = AppRadius.button,
  });

  @override
  Widget build(BuildContext context) {
    return TestoraButton(
      label: label,
      onTap: onTap,
      isLoading: isLoading,
      enabled: enabled,
      icon: icon,
      height: height,
      borderRadius: borderRadius,
      variant: TestoraButtonVariant.primary,
    );
  }
}

// =============================================================================
// TESTORA BADGE / CHIP
// =============================================================================

class TestoraBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;

  const TestoraBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bg = color ?? tokens.surfaceSecondary;
    final fg = textColor ?? tokens.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tokens.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TESTORA LOGO
// =============================================================================

class TestoraLogo extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;

  const TestoraLogo({
    super.key,
    this.size = 80,
    this.icon = Icons.school_rounded,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? tokens.surfaceSecondary,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor ?? tokens.cardBorder, width: 1.5),
      ),
      child: Icon(
        icon,
        size: size * 0.52,
        color: iconColor ?? tokens.textPrimary,
      ),
    );
  }
}

// =============================================================================
// SECTION TITLE
// =============================================================================

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class TestoraEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const TestoraEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.section),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tokens.surfaceSecondary,
                shape: BoxShape.circle,
                border: Border.all(color: tokens.border, width: 1),
              ),
              child: Icon(icon, size: 32, color: tokens.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: 180,
                child: TestoraButton(
                  label: actionLabel!,
                  onTap: onAction,
                  variant: TestoraButtonVariant.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}

// =============================================================================
// LOADING STATE
// =============================================================================

class TestoraLoading extends StatelessWidget {
  final String? message;

  const TestoraLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: tokens.textPrimary,
            strokeWidth: 2.4,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// SKELETON
// =============================================================================

class TestoraSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const TestoraSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppRadius.sm,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = scheme.surfaceContainerLow;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class TestoraListSkeleton extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const TestoraListSkeleton({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 84,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder:
          (_, _) =>
              TestoraSkeleton(height: itemHeight, borderRadius: AppRadius.card),
    );
  }
}
