import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/testora_widgets.dart';
import '../../application/payment_api_providers.dart';
import '../../domain/entities/payment_transaction.dart';
import '../../domain/repositories/payment_repository.dart';

enum _TransactionFilter {
  all,
  successful,
  pending,
  failed,
}

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  _TransactionFilter _filter = _TransactionFilter.all;
  final Set<String> _verifyingReferences = <String>{};

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(paymentHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            tooltip: 'Refresh payment history',
            onPressed: () => ref.invalidate(paymentHistoryProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: history.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => _HistoryErrorState(
            onRetry: () => ref.invalidate(paymentHistoryProvider),
          ),
          data: _buildHistory,
        ),
      ),
    );
  }

  Widget _buildHistory(List<PaymentTransaction> transactions) {
    final tokens = context.tokens;
    final successfulAmount = transactions
        .where((transaction) => transaction.isSuccessful)
        .fold<int>(
          0,
          (total, transaction) => total + transaction.amountKobo,
        );

    final filteredTransactions = transactions.where((transaction) {
      switch (_filter) {
        case _TransactionFilter.all:
          return true;
        case _TransactionFilter.successful:
          return transaction.status == PaymentStatus.success;
        case _TransactionFilter.pending:
          return transaction.status == PaymentStatus.pending ||
              transaction.status == PaymentStatus.initializing;
        case _TransactionFilter.failed:
          return transaction.status == PaymentStatus.failed;
      }
    }).toList(growable: false);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.refresh(paymentHistoryProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sp40,
        ),
        children: [
          Text(
            'Your payment history',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Review your exam purchases, payment references and transaction status.',
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Recent successful spend',
                  value: _formatNaira(successfulAmount),
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryMetric(
                  label: 'Transactions found',
                  value: transactions.length.toString(),
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          const SectionTitle(
            title: 'All transactions',
            subtitle: 'Your latest payment activity',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final filter in _TransactionFilter.values)
                ChoiceChip(
                  label: Text(_filterLabel(filter)),
                  selected: _filter == filter,
                  onSelected: (_) => setState(() => _filter = filter),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (filteredTransactions.isEmpty)
            _EmptyTransactionsState(
              hasAnyTransactions: transactions.isNotEmpty,
              filter: _filter,
            )
          else
            for (final transaction in filteredTransactions) ...[
              _TransactionCard(
                transaction: transaction,
                isVerifying: _verifyingReferences.contains(
                  transaction.reference,
                ),
                onVerify: () => _verifyTransaction(transaction),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          const SizedBox(height: AppSpacing.md),
          Text(
            'Payment records are retrieved securely from your Testora account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyTransaction(PaymentTransaction transaction) async {
    if (_verifyingReferences.contains(transaction.reference)) return;

    setState(() {
      _verifyingReferences.add(transaction.reference);
    });

    try {
      final updated = await ref
          .read(paymentRepositoryProvider)
          .verifyPayment(reference: transaction.reference);

      if (!mounted) return;

      ref.invalidate(paymentHistoryProvider);
      if (updated.isSuccessful) {
        ref.invalidate(userEntitlementsProvider);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.isSuccessful
                ? 'Payment confirmed. Your exam access has been refreshed.'
                : 'Payment is not confirmed yet. Please check again later.',
          ),
        ),
      );
    } on PaymentRepositoryException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We could not verify this payment. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _verifyingReferences.remove(transaction.reference);
        });
      }
    }
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: tokens.surfaceSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: tokens.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.transaction,
    required this.isVerifying,
    required this.onVerify,
  });

  final PaymentTransaction transaction;
  final bool isVerifying;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final statusColor = _statusColor(context, transaction.status);
    final statusLabel = _statusLabel(transaction.status);
    final transactionDate = transaction.paidAt ?? transaction.createdAt;
    final datePrefix = transaction.paidAt == null ? 'Created' : 'Paid';

    return TestoraCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tokens.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
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
                      _packageLabel(transaction.packageId),
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Paystack',
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(
                label: statusLabel,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'PAYMENT REFERENCE',
            style: TextStyle(
              color: tokens.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  transaction.reference,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy reference',
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: transaction.reference),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment reference copied.'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 17),
              ),
            ],
          ),
          Divider(color: tokens.divider),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      datePrefix,
                      style: TextStyle(
                        color: tokens.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(transactionDate),
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatNaira(transaction.amountKobo),
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (transaction.status == PaymentStatus.pending) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: isVerifying ? null : onVerify,
                icon: isVerifying
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.verified_outlined, size: 17),
                label: Text(isVerifying ? 'Verifying...' : 'Verify payment'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.circle),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  const _EmptyTransactionsState({
    required this.hasAnyTransactions,
    required this.filter,
  });

  final bool hasAnyTransactions;
  final _TransactionFilter filter;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final title = hasAnyTransactions
        ? 'No ' + _filterLabel(filter).toLowerCase() + ' transactions'
        : 'No payments yet';
    final message = hasAnyTransactions
        ? 'Try another filter to see your other payment records.'
        : 'When you purchase an exam package, your payment and receipt details will appear here.';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.section),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 42,
            color: tokens.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryErrorState extends StatelessWidget {
  const _HistoryErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 42,
              color: tokens.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Payment history is unavailable',
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Check your connection and try loading your transactions again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _filterLabel(_TransactionFilter filter) {
  switch (filter) {
    case _TransactionFilter.all:
      return 'All';
    case _TransactionFilter.successful:
      return 'Successful';
    case _TransactionFilter.pending:
      return 'Pending';
    case _TransactionFilter.failed:
      return 'Failed';
  }
}

String _statusLabel(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.initializing:
      return 'Processing';
    case PaymentStatus.pending:
      return 'Pending';
    case PaymentStatus.success:
      return 'Paid';
    case PaymentStatus.failed:
      return 'Failed';
  }
}

Color _statusColor(BuildContext context, PaymentStatus status) {
  final tokens = context.tokens;
  switch (status) {
    case PaymentStatus.initializing:
      return tokens.info;
    case PaymentStatus.pending:
      return tokens.warning;
    case PaymentStatus.success:
      return tokens.success;
    case PaymentStatus.failed:
      return tokens.error;
  }
}

String _packageLabel(String packageId) {
  switch (packageId) {
    case 'utme':
      return 'UTME / JAMB';
    case 'waec':
      return 'WAEC';
    case 'post-utme':
      return 'Post-UTME';
    case 'postgraduate':
      return 'Postgraduate';
    default:
      return packageId;
  }
}

String _formatNaira(int amountKobo) {
  final naira = amountKobo ~/ 100;
  final remainder = amountKobo.remainder(100);
  final formatted = naira.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => (match.group(1) ?? '') + ',',
  );
  final fraction = remainder == 0
      ? ''
      : '.' + remainder.toString().padLeft(2, '0');
  return '₦' + formatted + fraction;
}

String _formatDate(DateTime value) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = months[local.month - 1];
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';

  return day +
      ' ' +
      month +
      ' ' +
      local.year.toString() +
      ' • ' +
      hour.toString() +
      ':' +
      minute +
      ' ' +
      period;
}
