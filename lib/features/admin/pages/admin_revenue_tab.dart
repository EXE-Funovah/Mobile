import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/themed_card.dart';
import '../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../utils/admin_format.dart';
import '../widgets/admin_charts.dart';
import '../widgets/admin_ui.dart';
import 'admin_shell.dart';
import 'admin_order_detail_screen.dart';
import 'admin_webhook_screen.dart';

class AdminRevenueTab extends ConsumerWidget {
  const AdminRevenueTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final overview = ref.watch(adminOverviewProvider);
    final orders = ref.watch(adminBillingOrdersProvider);
    final status = ref.watch(adminOrderStatusProvider);
    final plan = ref.watch(adminOrderPlanProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      children: [
        const AdminRangeSegmented(),
        const SizedBox(height: 14),

        // Doanh thu + phân bổ trạng thái (từ overview)
        overview.when(
          loading: () => const _Loading(),
          error: (e, _) => _ErrorBox(
            message: '$e'.replaceFirst('Exception: ', ''),
            onRetry: () => ref.invalidate(adminOverviewProvider),
          ),
          data: (d) => _RevenueSummary(t: t, d: d),
        ),
        const SizedBox(height: 18),

        // Webhook PayOS (debug thanh toán)
        _webhookEntry(context, t),
        const SizedBox(height: 18),

        // Đơn thanh toán
        Text(
          'Đơn thanh toán',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: t.ink,
          ),
        ),
        const SizedBox(height: 10),
        _statusFilter(t, ref, status),
        const SizedBox(height: 8),
        AdminChips(
          t: t,
          labels: const ['Mọi gói', 'Gói tháng', 'Gói năm'],
          values: const [null, 'PRO_MONTHLY', 'PRO_YEARLY'],
          selected: plan,
          onSelect: (v) => ref.read(adminOrderPlanProvider.notifier).state = v,
        ),
        const SizedBox(height: 12),
        orders.when(
          loading: () => const _Loading(),
          error: (e, _) => _ErrorBox(
            message: '$e'.replaceFirst('Exception: ', ''),
            onRetry: () => ref.invalidate(adminBillingOrdersProvider),
          ),
          data: (d) => d.items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      'Không có đơn nào.',
                      style: TextStyle(color: t.inkMuted),
                    ),
                  ),
                )
              : Column(
                  children: d.items.map((o) => _OrderCard(t: t, o: o)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _webhookEntry(BuildContext context, AppTokens t) {
    return ThemedCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AdminWebhookScreen()),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.webhook, color: t.primary, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Webhook PayOS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: t.ink,
                  ),
                ),
                Text(
                  'Sự kiện thanh toán — soi lỗi xử lý',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: t.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: t.inkMuted),
        ],
      ),
    );
  }

  Widget _statusFilter(AppTokens t, WidgetRef ref, String? status) {
    const opts = [
      (null, 'Tất cả'),
      ('Paid', 'Đã trả'),
      ('Pending', 'Chờ'),
      ('Cancelled', 'Huỷ'),
      ('Expired', 'Hết hạn'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final o in opts)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () =>
                    ref.read(adminOrderStatusProvider.notifier).state = o.$1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: status == o.$1 ? t.primary : t.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: status == o.$1 ? t.primary : t.line,
                    ),
                  ),
                  child: Text(
                    o.$2,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: status == o.$1 ? Colors.white : t.ink2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RevenueSummary extends StatelessWidget {
  final AppTokens t;
  final AdminOverview d;
  const _RevenueSummary({required this.t, required this.d});

  @override
  Widget build(BuildContext context) {
    final revValues = d.paidRevenueSeries.map((e) => e.value).toList();
    final totalPaid = revValues.fold<num>(0, (s, e) => s + e);
    final maxStatus = d.paymentStatusDistribution.isEmpty
        ? 1.0
        : d.paymentStatusDistribution
              .map((e) => e.value)
              .reduce((a, b) => a > b ? a : b)
              .toDouble();

    return Column(
      children: [
        ThemedCard(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Doanh thu đã thanh toán',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: t.inkMuted,
                ),
              ),
              Text(
                '${vndShort(totalPaid)}đ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: t.ink,
                ),
              ),
              const SizedBox(height: 10),
              MiniAreaChart(values: revValues, color: t.primary, height: 150),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ThemedCard(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trạng thái thanh toán',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: t.ink,
                ),
              ),
              const SizedBox(height: 8),
              ...d.paymentStatusDistribution.map(
                (e) => HBar(
                  label: e.label,
                  valueText: compactNum(e.value),
                  fraction: maxStatus == 0 ? 0 : e.value / maxStatus,
                  color: e.label == 'Paid' ? t.ok : t.primary,
                  trackColor: t.surfaceSunken,
                  labelColor: t.ink2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AppTokens t;
  final AdminPaymentOrder o;
  const _OrderCard({required this.t, required this.o});

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = switch (o.status) {
      'Paid' => ('Đã trả', t.ok),
      'Pending' => ('Chờ', t.accent),
      'Cancelled' => ('Huỷ', t.inkMuted),
      'Expired' => ('Hết hạn', t.inkMuted),
      'Failed' => ('Lỗi', t.danger),
      _ => (o.status, t.inkMuted),
    };
    final planLabel = switch (o.planCode) {
      'PRO_MONTHLY' => 'Gói tháng',
      'PRO_YEARLY' => 'Gói năm',
      _ => o.planCode,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ThemedCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AdminOrderDetailScreen(order: o)),
        ),
        padding: const EdgeInsets.all(13),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.userName.isEmpty ? 'Người dùng #${o.userId}' : o.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                        ),
                      ),
                      Text(
                        o.userEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: t.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: t.line, height: 1),
            ),
            Row(
              children: [
                Text(
                  planLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: t.ink2,
                  ),
                ),
                const Spacer(),
                Text(
                  _date(o.paidAt ?? o.createdAt),
                  style: TextStyle(fontSize: 11.5, color: t.inkMuted),
                ),
                const SizedBox(width: 10),
                Text(
                  '${vnd(o.amount)}đ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: t.ink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _date(String iso) {
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 40),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _ErrorBox extends ConsumerWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: t.danger, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: t.ink2),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
