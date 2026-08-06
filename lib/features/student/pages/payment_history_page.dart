import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../data/api/billing_api.dart';
import '../../shared/widgets/themed_card.dart';
import '../providers/payment_history_provider.dart';
import 'pricing_page.dart' show formatVndPublic;

class PaymentHistoryPage extends ConsumerWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final ordersAsync = ref.watch(paymentHistoryProvider);

    return Scaffold(
      backgroundColor: t.appBg,
      appBar: AppBar(
        backgroundColor: t.appBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: t.ink),
        ),
        title: Text(
          'Lịch sử thanh toán',
          style: TextStyle(
            color: t.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorView(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(paymentHistoryProvider),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return _EmptyView(t: t);
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) => _OrderCard(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final PaymentOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final status = _statusText(order.status);
    final color = _statusColor(t, order.status);
    final subtitle = order.planCode == 'PRO_YEARLY'
        ? 'Premium năm'
        : 'Premium tháng';

    return ThemedCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: t.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mã đơn #${order.orderCode}',
                      style: TextStyle(
                        color: t.inkMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Số tiền', value: formatVndPublic(order.amount)),
          const SizedBox(height: 8),
          _InfoRow(label: 'Nhà cung cấp', value: order.provider),
          const SizedBox(height: 8),
          _InfoRow(label: 'Tạo lúc', value: _fmt(order.createdAt)),
          if (order.paidAt != null) ...[
            const SizedBox(height: 8),
            _InfoRow(label: 'Thanh toán lúc', value: _fmt(order.paidAt!)),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends ConsumerWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: t.inkMuted,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: t.ink,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  final AppTokens t;
  const _EmptyView({required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: t.inkMuted),
            const SizedBox(height: 12),
            Text(
              'Chưa có thanh toán nào',
              style: TextStyle(
                color: t.ink,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Lịch sử thanh toán sẽ xuất hiện ở đây sau khi bạn nâng cấp gói.',
              textAlign: TextAlign.center,
              style: TextStyle(color: t.inkMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusText(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return 'Đã thanh toán';
    case 'pending':
      return 'Đang chờ';
    case 'cancelled':
      return 'Đã hủy';
    case 'expired':
      return 'Hết hạn';
    default:
      return status.isEmpty ? 'Không rõ' : status;
  }
}

Color _statusColor(AppTokens t, String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return const Color(0xFF16A34A);
    case 'pending':
      return t.primary;
    case 'cancelled':
    case 'expired':
      return t.danger;
    default:
      return t.inkMuted;
  }
}

String _fmt(DateTime dt) {
  final local = dt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
}
