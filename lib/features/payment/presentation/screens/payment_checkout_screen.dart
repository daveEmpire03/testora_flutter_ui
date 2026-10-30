import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/testora_widgets.dart';
import '../../application/payment_api_providers.dart';
import '../../application/payment_catalog_provider.dart';
import '../../domain/entities/exam_payment_package.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_transaction.dart';
import '../../domain/repositories/payment_repository.dart';

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
    extends ConsumerState<PaymentCheckoutScreen>
    with WidgetsBindingObserver {
  PaymentMethodType _selectedMethod = PaymentMethodType.paystack;

  bool _isInitializingCheckout = false;
  bool _isVerifyingPayment = false;
  bool _checkoutWasOpened = false;
  bool _hasPackageAccess = false;

  String? _paymentReference;
  String? _authorizationUrl;
  String? _statusMessage;
  PaymentStatus? _paymentStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _checkoutWasOpened &&
        _paymentReference != null &&
        !_isVerifyingPayment &&
        !_isInitializingCheckout) {
      _checkoutWasOpened = false;
      unawaited(_verifyPayment());
    }
  }

  Future<void> _startPaystackCheckout() async {
    if (_isInitializingCheckout || _isVerifyingPayment) return;

    setState(() {
      _isInitializingCheckout = true;
      _paymentReference = null;
      _authorizationUrl = null;
      _paymentStatus = null;
      _statusMessage = null;
      _hasPackageAccess = false;
    });

    try {
      final transaction = await ref
          .read(paymentRepositoryProvider)
          .initializeCheckout(packageId: widget.packageId);

      if (!mounted) return;

      setState(() {
        _paymentReference = transaction.reference;
        _authorizationUrl = transaction.authorizationUrl;
        _paymentStatus = transaction.status;
      });

      await _openPaystackCheckout();
    } on PaymentRepositoryException catch (error) {
      if (mounted) {
        setState(() => _statusMessage = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _statusMessage =
              'We could not start checkout. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializingCheckout = false);
      }
    }
  }

  Future<void> _openPaystackCheckout() async {
    final checkoutUrl = _authorizationUrl;
    if (checkoutUrl == null || checkoutUrl.isEmpty) {
      setState(
        () => _statusMessage =
            'The checkout link is unavailable. Please start a new payment.',
      );
      return;
    }

    final uri = Uri.tryParse(checkoutUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'checkout.paystack.com') {
      setState(
        () => _statusMessage =
            'The checkout link is invalid. Please start a new payment.',
      );
      return;
    }

    _checkoutWasOpened = true;
    setState(
      () => _statusMessage =
          'Complete payment in Paystack, then return here to verify it.',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _checkoutWasOpened = false;
        setState(
          () => _statusMessage =
              'Could not open Paystack. Check your browser and try again.',
        );
      }
    } catch (_) {
      _checkoutWasOpened = false;
      if (mounted) {
        setState(
          () => _statusMessage =
              'Could not open Paystack. Check your browser and try again.',
        );
      }
    }
  }

  Future<void> _verifyPayment() async {
    final reference = _paymentReference;
    if (reference == null || _isVerifyingPayment) return;

    setState(() {
      _isVerifyingPayment = true;
      _statusMessage = 'Checking your payment with Paystack...';
    });

    try {
      final transaction = await ref
          .read(paymentRepositoryProvider)
          .verifyPayment(reference: reference);

      if (!mounted) return;

      setState(() => _paymentStatus = transaction.status);

      if (transaction.status == PaymentStatus.success) {
        final hasEntitlement = await ref
            .read(paymentRepositoryProvider)
            .hasActiveEntitlement(packageId: widget.packageId);

        if (!mounted) return;

        if (hasEntitlement) {
          setState(() {
            _hasPackageAccess = true;
            _statusMessage =
                'Your payment is verified and exam access is now unlocked.';
          });
        } else {
          setState(() {
            _hasPackageAccess = false;
            _statusMessage =
                'Your payment is verified, but access is not visible yet. Please check again.';
          });
        }
      } else if (transaction.status == PaymentStatus.failed) {
        setState(() {
          _statusMessage =
              'Paystack reports that this payment was not completed. You can try again.';
        });
      } else {
        setState(() {
          _statusMessage =
              'Your payment is not confirmed yet. Complete checkout and check again.';
        });
      }
    } on PaymentRepositoryException catch (error) {
      if (mounted) {
        setState(() => _statusMessage = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _statusMessage =
              'We could not verify your payment. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifyingPayment = false);
      }
    }
  }

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
                color: context.tokens.textPrimary,
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
                color: context.tokens.textSecondary,
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
              onTap: () {
                setState(() => _selectedMethod = PaymentMethodType.paystack);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _PaymentMethodCard(
              method: PaymentMethodType.manualTransfer,
              icon: Icons.account_balance_outlined,
              selected: _selectedMethod == PaymentMethodType.manualTransfer,
              onTap: () {
                setState(
                  () => _selectedMethod = PaymentMethodType.manualTransfer,
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_selectedMethod == PaymentMethodType.paystack)
              _PaystackInfo(
                selectedPackage: selectedPackage,
                isInitializingCheckout: _isInitializingCheckout,
                isVerifyingPayment: _isVerifyingPayment,
                paymentReference: _paymentReference,
                authorizationUrl: _authorizationUrl,
                paymentStatus: _paymentStatus,
                statusMessage: _statusMessage,
                hasPackageAccess: _hasPackageAccess,
                onContinue: _startPaystackCheckout,
                onReopenCheckout: _openPaystackCheckout,
                onVerifyPayment: _verifyPayment,
                onDone: () => Navigator.of(context).maybePop(),
              )
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
              color: selected ? tokens.textPrimary : tokens.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: Border.all(color: tokens.border),
            ),
            child: Icon(
              icon,
              color: selected ? tokens.background : tokens.textPrimary,
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
  const _PaystackInfo({
    required this.selectedPackage,
    required this.isInitializingCheckout,
    required this.isVerifyingPayment,
    required this.paymentReference,
    required this.authorizationUrl,
    required this.paymentStatus,
    required this.statusMessage,
    required this.hasPackageAccess,
    required this.onContinue,
    required this.onReopenCheckout,
    required this.onVerifyPayment,
    required this.onDone,
  });

  final ExamPaymentPackage selectedPackage;
  final bool isInitializingCheckout;
  final bool isVerifyingPayment;
  final String? paymentReference;
  final String? authorizationUrl;
  final PaymentStatus? paymentStatus;
  final String? statusMessage;
  final bool hasPackageAccess;
  final VoidCallback onContinue;
  final VoidCallback onReopenCheckout;
  final VoidCallback onVerifyPayment;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (hasPackageAccess) {
      return Column(
        children: [
          TestoraCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.success,
                  size: 25,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment verified',
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${selectedPackage.name} access is now unlocked.',
                        style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TestoraButton(
            label: 'Done',
            icon: Icons.check_rounded,
            onTap: onDone,
          ),
        ],
      );
    }

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
                  'Paystack handles the secure online checkout. Testora verifies the transaction with Paystack before unlocking exam access. The displayed package price is informational; the server determines the amount charged.',
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
        if (paymentReference != null) ...[
          const SizedBox(height: AppSpacing.md),
          TestoraCard(
            backgroundColor: tokens.surfaceSecondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paymentStatus == PaymentStatus.failed
                      ? 'Payment not completed'
                      : 'Payment awaiting confirmation',
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Reference: $paymentReference',
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 11,
                  ),
                ),
                if (statusMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    statusMessage!,
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (paymentStatus == PaymentStatus.failed)
            TestoraButton(
              label: 'Try payment again',
              icon: Icons.refresh_rounded,
              isLoading: isInitializingCheckout,
              enabled: !isVerifyingPayment,
              onTap: onContinue,
            )
          else ...[
            if (authorizationUrl != null) ...[
              TestoraButton(
                label: 'Reopen Paystack checkout',
                icon: Icons.open_in_new_rounded,
                variant: TestoraButtonVariant.secondary,
                enabled: !isVerifyingPayment,
                onTap: onReopenCheckout,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            TestoraButton(
              label: 'Verify payment',
              icon: Icons.verified_outlined,
              isLoading: isVerifyingPayment,
              enabled: !isInitializingCheckout,
              onTap: onVerifyPayment,
            ),
          ],
        ] else ...[
          if (statusMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                statusMessage!,
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          TestoraButton(
            label: 'Continue with Paystack',
            icon: Icons.arrow_forward_rounded,
            isLoading: isInitializingCheckout,
            enabled: !isVerifyingPayment,
            onTap: onContinue,
          ),
        ],
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
