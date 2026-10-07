import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/testora_widgets.dart';
import '../../application/payment_catalog_provider.dart';
import '../../domain/entities/exam_payment_package.dart';
import '../../domain/entities/payment_method.dart';

class PaymentCheckoutScreen extends ConsumerStatefulWidget {
  const PaymentCheckoutScreen({
    super.key,
    required this.packageId,
  });

  final String packageId;

  @override
  ConsumerState<PaymentCheckoutScreen> createState() =>
      _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState
    extends ConsumerState<PaymentCheckoutScreen> {
  PaymentMethodType _selectedMethod = PaymentMethodType.paystack;

  @override
  Widget build(BuildContext context) {
    final selectedPackage = ref.watch(
      paymentPackageProvider(widget.packageId),
    );

    if (selectedPackage == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const TestoraEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Package not found',
          message: 'This exam payment package is not available.',
        ),
      );
    }

    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sp40,
          ),
          children: [
            Text(
              'Complete payment',
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 24,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Review your exam package and choose how you want to pay.',
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            _OrderSummaryCard(selectedPackage: selectedPackage),

            const SizedBox(height: AppSpacing.section),
            const SectionTitle(
              title: 'Payment method',
              subtitle: 'Choose one option to continue',
            ),
            const SizedBox(height: AppSpacing.md),

            _PaymentMethodCard(
              method: PaymentMethodType.paystack,
              icon: Icons.credit_card_rounded,
              selected: _selectedMethod == PaymentMethodType.paystack,
              onTap:
                  () => setState(
                    () => _selectedMethod = PaymentMethodType.paystack,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PaymentMethodCard(
              method: PaymentMethodType.manualTransfer,
              icon: Icons.account_balance_outlined,
              selected: _selectedMethod == PaymentMethodType.manualTransfer,
              onTap:
                  () => setState(
                    () => _selectedMethod = PaymentMethodType.manualTransfer,
                  ),
            ),

            const SizedBox(height: AppSpacing.xl),

            if (_selectedMethod == PaymentMethodType.paystack)
              _PaystackInfo(selectedPackage: selectedPackage)
            else
              _ManualTransferInfo(selectedPackage: selectedPackage),
          ],
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.selectedPackage});

  final ExamPaymentPackage selectedPackage;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraCard(
      backgroundColor: tokens.surfaceSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order summary',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SummaryRow(label: 'Exam', value: selectedPackage.name),
          const SizedBox(height: AppSpacing.md),
          const _SummaryRow(label: 'Access', value: 'Exam package'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Divider(),
          ),
          _SummaryRow(
            label: 'Total',
            value: _formatNaira(selectedPackage.priceNaira),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 12.5,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: emphasize ? 17 : 13,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethodType method;
  final IconData icon;
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color:
                  selected
                      ? tokens.textPrimary
                      : tokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: Border.all(color: tokens.border),
            ),
            child: Icon(
              icon,
              color:
                  selected
                      ? tokens.background
                      : tokens.textPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.label,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  method.description,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 11.5,
                    height: 1.4,
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

class _PaystackInfo extends StatelessWidget {
  const _PaystackInfo({required this.selectedPackage});

  final ExamPaymentPackage selectedPackage;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: [
        TestoraCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.success,
                size: 21,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Paystack will handle the secure online checkout. The amount sent to Paystack will be ${_formatNaira(selectedPackage.priceNaira)}.',
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
        const SizedBox(height: AppSpacing.md),
        TestoraButton(
          label: 'Continue with Paystack',
          icon: Icons.arrow_forward_rounded,
          onTap: () => _showPaystackPending(context),
        ),
      ],
    );
  }

  void _showPaystackPending(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            icon: const Icon(Icons.credit_card_rounded),
            title: const Text('Paystack setup required'),
            content: const Text(
              'The checkout UI is ready. Live Paystack charging will be connected to the Testora backend so payment verification and exam access cannot be bypassed.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Okay'),
              ),
            ],
          ),
    );
  }
}

class _ManualTransferInfo extends StatelessWidget {
  const _ManualTransferInfo({required this.selectedPackage});

  final ExamPaymentPackage selectedPackage;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TestoraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manual bank transfer',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Transfer ${_formatNaira(selectedPackage.priceNaira)} to the Testora bank account. Bank details will be configured here before production release.',
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  border: Border.all(color: tokens.border),
                ),
                child: Text(
                  'Bank account details not configured yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TestoraButton(
          label: 'Submit transfer proof',
          icon: Icons.upload_file_outlined,
          enabled: false,
          onTap: () {},
        ),
      ],
    );
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
