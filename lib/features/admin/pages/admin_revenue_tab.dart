import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/themed_card.dart';
import '../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../utils/admin_format.dart';
import '../widgets/admin_charts.dart';
import 'admin_shell.dart';

class AdminRevenueTab extends ConsumerWidget {
  const AdminRevenueTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final async = ref.watch(adminRevenueProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      children: [
        const AdminRangeSegmented(),
        const SizedBox(height: 14),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: t.danger, size: 40),
                const SizedBox(height: 12),
                Text(
                  '$e'.replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.ink2),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(adminRevenueProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
          data: (d) => _Body(t: t, d: d),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  final AppTokens t;
  final AdminRevenue d;
  const _Body({required this.t, required this.d});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('ARR (ước tính)', vndShort(d.arr)),
      ('ARPU', '${vnd(d.arpu)}đ'),
      ('Tỷ lệ rời bỏ', d.churnRate == null ? '—' : '${d.churnRate}%'),
      ('LTV trung bình', d.ltv == null ? '—' : vndShort(d.ltv!)),
    ];

    final totalPlan = d.planDistribution.fold<double>(
      0,
      (s, e) => s + e.value.toDouble(),
    );
    final premium = d.planDistribution
        .where((e) => e.label.toLowerCase().contains('premium'))
        .fold<double>(0, (s, e) => s + e.value.toDouble());
    final convPct = totalPlan > 0 ? (premium / totalPlan * 100) : 0;
    final maxFunnel = d.funnel.isEmpty
        ? 1.0
        : d.funnel
              .map((e) => e.value)
              .reduce((a, b) => a > b ? a : b)
              .toDouble();

    return Column(
      children: [
        // MRR area
        ThemedCard(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MRR hiện tại',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: t.inkMuted,
                ),
              ),
              Text(
                '${vndShort(d.mrr)}/tháng',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: t.ink,
                ),
              ),
              const SizedBox(height: 10),
              MiniAreaChart(
                values: d.mrrSeries.map((e) => e.value).toList(),
                color: t.primary,
                height: 150,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Metrics 2x2
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.0,
          children: metrics
              .map(
                (m) => ThemedCard(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        m.$2,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.$1,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: t.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 14),

        // Plan distribution donut + legend
        ThemedCard(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phân bổ gói',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: t.ink,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  DonutChart(
                    segments: d.planDistribution
                        .map((e) => (e.value, _hex(e.color, t.primary)))
                        .toList(),
                    centerText:
                        '${convPct.toStringAsFixed(1).replaceAll('.', ',')}%',
                    centerSub: 'trả phí',
                    centerTextColor: t.ink,
                    centerSubColor: t.inkMuted,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: d.planDistribution
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _hex(e.color, t.primary),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      e.label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: t.ink2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    vnd(e.value),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: t.ink,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Funnel
        ThemedCard(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phễu chuyển đổi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: t.ink,
                ),
              ),
              const SizedBox(height: 8),
              ...d.funnel.asMap().entries.map(
                (e) => HBar(
                  label: e.value.label,
                  valueText: vnd(e.value.value),
                  fraction: e.value.value / maxFunnel,
                  color: e.key == d.funnel.length - 1 ? t.accent : t.primary,
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

Color _hex(String? hex, Color fallback) {
  if (hex == null) return fallback;
  final h = hex.replaceFirst('#', '');
  final v = int.tryParse(h.length == 6 ? 'FF$h' : h, radix: 16);
  return v == null ? fallback : Color(v);
}
