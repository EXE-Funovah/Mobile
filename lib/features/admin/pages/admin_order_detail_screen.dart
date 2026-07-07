import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/themed_card.dart';
import '../data/admin_models.dart';
import '../utils/admin_format.dart';
import '../widgets/admin_ui.dart';

/// H. Chi tiết đơn thanh toán (dữ liệu lấy từ list `billing/orders`).
class AdminOrderDetailScreen extends ConsumerWidget {
  final AdminPaymentOrder order;
  const AdminOrderDetailScreen({super.key, required this.order});

  String _orderTone(String s) => switch (s) {
    'Paid' => 'ok',
    'Pending' => 'accent',
    _ => 'down',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final o = order;
    final tn = _orderTone(o.status);
    final timeline = [
      (label: 'Tạo đơn', at: o.createdAt, icon: Icons.add, on: true, color: t.primary),
      (
        label: 'Thanh toán',
        at: o.paidAt,
        icon: Icons.check,
        on: o.paidAt != null,
        color: t.ok,
      ),
      (
        label: 'Huỷ',
        at: o.cancelledAt,
        icon: Icons.block,
        on: o.cancelledAt != null,
        color: t.danger,
      ),
    ];

    return AdminDetailScaffold(
      title: 'Chi tiết đơn',
      children: [
        // Số tiền
        ThemedCard(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 15),
          child: Column(
            children: [
              Text(
                planName(o.planCode),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: t.inkMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                vndFull(o.amount),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: t.ink,
                ),
              ),
              const SizedBox(height: 12),
              AdminBadge(
                t: t,
                label: orderStatusName(o.status),
                tone: tn,
                icon: o.status == 'Paid'
                    ? Icons.check
                    : o.status == 'Pending'
                    ? Icons.schedule
                    : Icons.block,
              ),
            ],
          ),
        ),
        AdminGroup(
          t: t,
          label: 'Thông tin đơn',
          child: AdminRows(
            t: t,
            children: [
              AdminInfoRow.text(t, 'Mã đơn', '${o.orderCode}', mono: true),
              AdminInfoRow.text(t, 'Mã PayOS', o.payosReference ?? '—', mono: true),
              AdminInfoRow.text(t, 'Gói', planName(o.planCode)),
              AdminInfoRow.text(t, 'Nhà cung cấp', o.provider),
            ],
          ),
        ),
        AdminGroup(
          t: t,
          label: 'Mốc thời gian',
          child: Column(
            children: [
              for (var i = 0; i < timeline.length; i++)
                _timelineRow(
                  t,
                  timeline[i].label,
                  timeline[i].at,
                  timeline[i].icon,
                  timeline[i].on,
                  timeline[i].color,
                  last: i == timeline.length - 1,
                ),
            ],
          ),
        ),
        AdminGroup(
          t: t,
          label: 'Người mua',
          child: AdminPersonCard(
            t: t,
            name: o.userName.isEmpty ? 'Người dùng #${o.userId}' : o.userName,
            email: o.userEmail,
            deleted: o.userIsDeleted,
            meta:
                '${o.subscriptionTier} · ${o.isPremiumActive ? 'còn hiệu lực đến ${fmtDate(o.premiumExpiresAt)}' : 'hết hiệu lực'}',
          ),
        ),
      ],
    );
  }

  Widget _timelineRow(
    AppTokens t,
    String label,
    String? at,
    IconData icon,
    bool on,
    Color activeColor, {
    required bool last,
  }) {
    final col = on ? activeColor : t.inkMuted;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on
                      ? col.withValues(alpha: 0.12)
                      : t.surfaceSunken,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 15, color: col),
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: t.line,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(top: 4, bottom: last ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: on ? t.ink : t.inkMuted,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  at == null ? '—' : fmtDateTime(at),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: t.inkMuted,
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
