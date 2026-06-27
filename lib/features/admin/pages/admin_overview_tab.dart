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

class AdminOverviewTab extends ConsumerWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final async = ref.watch(adminOverviewProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      children: [
        const AdminRangeSegmented(),
        const SizedBox(height: 14),
        async.when(
          loading: () => const _Loading(),
          error: (e, _) => _ErrorBox(
            message: '$e'.replaceFirst('Exception: ', ''),
            onRetry: () => ref.invalidate(adminOverviewProvider),
          ),
          data: (d) => _OverviewBody(t: t, data: d),
        ),
      ],
    );
  }
}

class _OverviewBody extends StatelessWidget {
  final AppTokens t;
  final AdminOverview data;
  const _OverviewBody({required this.t, required this.data});

  IconData _icon(String key) => switch (key) {
    'users' => Icons.people_rounded,
    'mau' => Icons.graphic_eq_rounded,
    'mrr' => Icons.account_balance_wallet_rounded,
    'conv' => Icons.adjust_rounded,
    _ => Icons.insights_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final maxUsage = data.featureUsage.isEmpty
        ? 1.0
        : data.featureUsage
              .map((e) => e.value)
              .reduce((a, b) => a > b ? a : b)
              .toDouble();

    return Column(
      children: [
        // KPI grid 2x2
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: data.kpis
              .map((k) => _KpiCard(t: t, kpi: k, icon: _icon(k.key)))
              .toList(),
        ),
        const SizedBox(height: 14),

        // MRR card
        ThemedCard(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(t, 'Doanh thu định kỳ', 'MRR · 12 tháng'),
              const SizedBox(height: 12),
              MiniAreaChart(
                values: data.mrrSeries.map((e) => e.value).toList(),
                color: t.primary,
                height: 130,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: data.mrrSeries
                    .where((e) => data.mrrSeries.indexOf(e) % 3 == 0)
                    .map(
                      (e) => Text(
                        e.label,
                        style: TextStyle(fontSize: 9.5, color: t.inkMuted),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Feature usage
        ThemedCard(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(t, 'Sử dụng tính năng', 'Tổng tích luỹ'),
              const SizedBox(height: 8),
              ...data.featureUsage.map(
                (f) => HBar(
                  label: f.label,
                  valueText: compactNum(f.value),
                  fraction: f.value / maxUsage,
                  color: _color(f.color, t.primary),
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

class _KpiCard extends StatelessWidget {
  final AppTokens t;
  final AdminKpi kpi;
  final IconData icon;
  const _KpiCard({required this.t, required this.kpi, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ThemedCard(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: t.primarySoft,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: t.primary),
              ),
              const Spacer(),
              if (kpi.deltaPercent != 0)
                TrendPill(
                  percent: kpi.deltaPercent,
                  up: kpi.up,
                  okColor: t.ok,
                  downColor: t.danger,
                ),
            ],
          ),
          Text(
            formatKpi(kpi),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: t.ink,
            ),
          ),
          Text(
            kpi.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: t.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _cardTitle(AppTokens t, String title, String sub) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      title,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: t.ink),
    ),
    Text(
      sub,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: t.inkMuted,
      ),
    ),
  ],
);

Color _color(String? hex, Color fallback) {
  if (hex == null) return fallback;
  final h = hex.replaceFirst('#', '');
  final v = int.tryParse(h.length == 6 ? 'FF$h' : h, radix: 16);
  return v == null ? fallback : Color(v);
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 60),
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
      padding: const EdgeInsets.only(top: 50),
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
