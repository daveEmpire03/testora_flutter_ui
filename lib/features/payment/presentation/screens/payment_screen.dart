import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/testora_widgets.dart';
import '../../application/payment_catalog_provider.dart';
import '../../domain/entities/exam_payment_package.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final packages = ref.watch(paymentPackagesProvider);

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
            'Choose the examination you want to unlock on Testora.',
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          _AccessInfoCard(),

          const SizedBox(height: AppSpacing.section),
          const SectionTitle(
            title: 'Exam access',
            subtitle: 'Each examination has its own access price',
          ),
          const SizedBox(height: AppSpacing.md),

          for (var index = 0; index < packages.length; index++) ...[
            _ExamPaymentCard(
              package: packages[index],
              onTap:
                  () => context.pushNamed(
                    'payment-checkout',
                    pathParameters: {'packageId': packages[index].id},
                  ),
            ),
            if (index != packages.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],

          const SizedBox(height: AppSpacing.section),
          TestoraCard(
            backgroundColor: tokens.surfaceSecondary,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: tokens.textPrimary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'After selecting an exam, you can choose Paystack for online payment or Manual Transfer for bank payment.',
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 12,
                      height: 1.5,
                    ),
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

class _AccessInfoCard extends StatelessWidget {
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
              Icons.lock_open_outlined,
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
                  'Unlock exam access',
                  style: TextStyle(
                    color: tokens.background,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Pay only for the exam package you need.',
                  style: TextStyle(
                    color: tokens.background.withValues(alpha: 0.72),
                    fontSize: 12,
                    height: 1.4,
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

class _ExamPaymentCard extends StatelessWidget {
  const _ExamPaymentCard({
    required this.package,
    required this.onTap,
  });

  final ExamPaymentPackage package;
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: Border.all(color: tokens.border),
            ),
            child: Icon(
              _iconFor(package.iconKey),
              color: tokens.textPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  package.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNaira(package.priceNaira),
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: tokens.textSecondary,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(String key) {
  switch (key) {
    case 'school':
      return Icons.school_outlined;
    case 'menu_book':
      return Icons.menu_book_outlined;
    case 'account_balance':
      return Icons.account_balance_outlined;
    case 'workspace_premium':
      return Icons.workspace_premium_outlined;
    default:
      return Icons.quiz_outlined;
  }
}

String _formatNaira(int amount) {
  final raw = amount.toString();
  final buffer = StringBuffer();

  for (var index = 0; index < raw.length; index++) {
    if (index > 0 && (raw.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(raw[index]);
  }

  return '₦$buffer';
}
