import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testora_flutter_ui/features/payment/data/testora_payment_api.dart';
import 'package:testora_flutter_ui/features/payment/data/testora_paystack_checkout.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/testora_widgets.dart';
import '../../application/payment_catalog_provider.dart';
import '../../domain/entities/exam_payment_package.dart';
import '../../domain/entities/payment_method.dart';
import '../payment_ui_helpers.dart';

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
  final TextEditingController _emailController = TextEditingController();
  bool _isStartingPayment = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _startPaystackCheckout(ExamPaymentPackage package) async {
    final email = _emailController.text.trim();
    if (!email.contains('@') || !email.split('@').last.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid email address to receive your payment receipt.',
          ),
        ),
      );
      return;
    }
    setState(() => _isStartingPayment = true);
    final api = TestoraPaymentApi();
    try {
      final pending = await TestoraPaystackCheckout(api).begin(
        email: email,
        packageCode: package.id,
      );
      if (!mounted) {
        api.close();
        return;
      }
      final shouldVerify = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Complete your Paystack payment'),
          content: const Text(
            'Finish payment in the browser. When you return here, tap Verify payment. '
            'Testora will confirm the transaction directly with Paystack before showing success.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Verify payment'),
            ),
          ],
        ),
      );
      if (shouldVerify == true) {
        final result = await TestoraPaystackCheckout(api).verifyPendingPayment(pending);
        if (!mounted) {
          api.close();
          return;
        }
        final success = result['status'] == 'success';
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: Icon(
              success ? Icons.check_circle_outline : Icons.hourglass_top_rounded,
            ),
            title: Text(success ? 'Payment confirmed' : 'Payment not confirmed yet'),
            content: Text(
              success
                  ? 'Payment was verified by Paystack. Exam access can now be enabled for this package.'
                  : 'Paystack has not confirmed a successful payment yet. If you completed checkout, wait briefly and verify again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      }
      api.close();
    } on TestoraPaymentException catch (e) {
      api.close();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStartingPayment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final packageAsync = ref.watch(paymentPackageProvider(widget.packageId));

    return packageAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const TestoraLoading(message: 'Loading package…'),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: TestoraEmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Could not load package',
          message: error.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(paymentPackageProvider(widget.packageId)),
        ),
      ),
      data: (selectedPackage) {
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

                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    hintText: 'student@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
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
                  onTap: () => setState(
                    () => _selectedMethod = PaymentMethodType.paystack,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _PaymentMethodCard(
                  method: PaymentMethodType.manualTransfer,
                  icon: Icons.account_balance_outlined,
                  selected: _selectedMethod == PaymentMethodType.manualTransfer,
                  onTap: () => setState(
                    () => _selectedMethod = PaymentMethodType.manualTransfer,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                if (_selectedMethod == PaymentMethodType.paystack)
                  _PaystackInfo(
                    selectedPackage: selectedPackage,
                    isLoading: _isStartingPayment,
                    onCheckout: () => _startPaystackCheckout(selectedPackage),
                  )
                else
                  _ManualTransferInfo(selectedPackage: selectedPackage),
              ],
            ),
          ),
        );
      },
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
            value: formatNaira(selectedPackage.priceNaira),
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
  const _PaystackInfo({required this.selectedPackage, required this.onCheckout, required this.isLoading});

  final ExamPaymentPackage selectedPackage;
  final VoidCallback onCheckout;
  final bool isLoading;

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
                  'Paystack will handle the secure online checkout. The amount sent to Paystack will be ${formatNaira(selectedPackage.priceNaira)}.',
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
          label: isLoading ? 'Opening secure checkout…' : 'Continue with Paystack',
          icon: Icons.arrow_forward_rounded,
          enabled: !isLoading,
          onTap: onCheckout,
        ),
      ],
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
                'Transfer ${formatNaira(selectedPackage.priceNaira)} to the Testora bank account. Bank details will be configured here before production release.',
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
