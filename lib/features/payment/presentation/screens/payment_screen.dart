import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/testora_widgets.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

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
            'Payment',
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
            'Manage your Testora plan, payments and billing.',
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          const _CurrentPlanCard(),

          const SizedBox(height: AppSpacing.section),
          const SectionTitle(
            title: 'Upgrade your plan',
            subtitle: 'Unlock more practice features when billing is enabled',
          ),
          const SizedBox(height: AppSpacing.md),

          const _PlanCard(
            title: 'Free',
            subtitle: 'For everyday practice',
            icon: Icons.school_outlined,
            features: [
              'Practice questions',
              'Basic quiz results',
              'Bookmarks',
            ],
            selected: true,
          ),

          const SizedBox(height: AppSpacing.md),

          const _PlanCard(
            title: 'Pro',
            subtitle: 'For serious exam preparation',
            icon: Icons.workspace_premium_outlined,
            features: [
              'More practice questions',
              'Advanced performance insights',
              'Full solution review',
              'Premium mock exam tools',
            ],
          ),

          const SizedBox(height: AppSpacing.section),
          const SectionTitle(title: 'Payment method'),
          const SizedBox(height: AppSpacing.md),

          TestoraCard(
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
                  child: Icon(
                    Icons.credit_card_outlined,
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
                        'No payment method',
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'A payment method will appear here after billing is connected.',
                        style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.section),
          const SectionTitle(title: 'Billing history'),
          const SizedBox(height: AppSpacing.md),

          const TestoraEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No payments yet',
            message: 'Your completed Testora payments will appear here.',
          ),
        ],
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: tokens.textPrimary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: tokens.background.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: tokens.background,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current plan',
                  style: TextStyle(
                    color: tokens.background.withValues(alpha: 0.70),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Free',
                  style: TextStyle(
                    color: tokens.background,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: tokens.background.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.circle),
            ),
            child: Text(
              'ACTIVE',
              style: TextStyle(
                color: tokens.background,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.features,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> features;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraCard(
      isSelected: selected,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      selected
                          ? tokens.textPrimary
                          : tokens.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: tokens.border),
                ),
                child: Icon(
                  icon,
                  color:
                      selected
                          ? tokens.background
                          : tokens.textPrimary,
                  size: 21,
                ),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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
              if (selected)
                const TestoraBadge(label: 'Current'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final feature in features) ...[
            _FeatureRow(label: feature),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (!selected) ...[
            const SizedBox(height: AppSpacing.md),
            TestoraButton(
              label: 'Upgrade',
              icon: Icons.lock_open_rounded,
              enabled: false,
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                'Billing integration not connected yet',
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          size: 17,
          color: AppColors.success,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
