import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/themed_card.dart';
import '../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../utils/admin_format.dart';
import '../widgets/admin_ui.dart';

/// I. Webhook Events (PayOS) — debug thanh toán (push từ tab Doanh thu).
class AdminWebhookScreen extends ConsumerStatefulWidget {
  const AdminWebhookScreen({super.key});

  @override
  ConsumerState<AdminWebhookScreen> createState() => _AdminWebhookScreenState();
}

class _AdminWebhookScreenState extends ConsumerState<AdminWebhookScreen> {
  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    final filter = ref.watch(adminWebhookProcessedProvider);
    final async = ref.watch(adminWebhookProvider);

    return AdminDetailScaffold(
      title: 'Webhook PayOS',
      children: [
        AdminChips(
          t: t,
          labels: const ['Tất cả', 'Đã xử lý', 'Có lỗi'],
          values: const ['__all', '__ok', '__err'],
          selected: filter == null ? '__all' : (filter ? '__ok' : '__err'),
          onSelect: (v) => ref.read(adminWebhookProcessedProvider.notifier).state =
              v == '__all' ? null : (v == '__ok'),
        ),
        async.when(
          loading: () => AdminAsyncSlivers.loading(),
          error: (e, _) => AdminAsyncSlivers.error(t, e, () => ref.invalidate(adminWebhookProvider)),
          data: (d) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (d.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text('Không có sự kiện nào.', style: TextStyle(color: t.inkMuted)),
                  ),
                )
              else
                ...d.items.map((w) => _card(t, w)),
              AdminAsyncSlivers.footer(t, d.items.length, d.total),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card(AppTokens t, AdminWebhookEvent w) {
    final err = !w.isProcessed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ThemedCard(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (err ? t.danger : t.ok).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    err ? Icons.warning_amber_rounded : Icons.check,
                    size: 18,
                    color: err ? t.danger : t.ok,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.orderCode == null ? '—' : '${w.orderCode}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        '${w.provider} · ${fmtDateTime(w.processedAt)}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.inkMuted),
                      ),
                    ],
                  ),
                ),
                AdminBadge(t: t, label: err ? 'Lỗi' : 'OK', tone: err ? 'down' : 'ok'),
              ],
            ),
            if (err && (w.processingError?.isNotEmpty ?? false))
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                decoration: BoxDecoration(
                  color: t.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  w.processingError!,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: t.danger,
                    height: 1.45,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
