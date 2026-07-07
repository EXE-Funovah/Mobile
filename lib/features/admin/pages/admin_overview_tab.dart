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
    'totalUsers' => Icons.people_rounded,
    'newUsers' => Icons.person_add_alt_1_rounded,
    'activeUsers' => Icons.graphic_eq_rounded,
    'paidRevenue' => Icons.account_balance_wallet_rounded,
    _ => Icons.insights_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final revValues = data.paidRevenueSeries.map((e) => e.value).toList();
    final totalPaid = revValues.fold<num>(0, (s, e) => s + e);

    final subTotal = data.subscriptionDistribution.fold<double>(
      0,
      (s, e) => s + e.value.toDouble(),
    );
    final premium = data.subscriptionDistribution
        .where((e) => e.label.toLowerCase().contains('premium') &&
            !e.label.toLowerCase().contains('hết'))
        .fold<double>(0, (s, e) => s + e.value.toDouble());
    final premiumPct = subTotal > 0 ? premium / subTotal * 100 : 0;

    final subColors = [t.inkMuted, t.ok, t.accent];

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

        // Paid revenue series
        ThemedCard(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(t, 'Doanh thu đã thanh toán', '12 tháng gần nhất'),
              const SizedBox(height: 4),
              Text(
                '${vndShort(totalPaid)}đ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: t.ink,
                ),
              ),
              const SizedBox(height: 10),
              MiniAreaChart(values: revValues, color: t.primary, height: 130),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < data.paidRevenueSeries.length; i += 3)
                    Text(
                      data.paidRevenueSeries[i].label,
                      style: TextStyle(fontSize: 9.5, color: t.inkMuted),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Subscription distribution donut
        if (subTotal > 0)
          ThemedCard(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardTitle(t, 'Phân bổ gói', 'Freemium · Premium'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    DonutChart(
                      segments: [
                        for (var i = 0;
                            i < data.subscriptionDistribution.length;
                            i++)
                          (
                            data.subscriptionDistribution[i].value,
                            subColors[i % subColors.length],
                          ),
                      ],
                      centerText:
                          '${premiumPct.toStringAsFixed(1).replaceAll('.', ',')}%',
                      centerSub: 'trả phí',
                      centerTextColor: t.ink,
                      centerSubColor: t.inkMuted,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          for (var i = 0;
                              i < data.subscriptionDistribution.length;
                              i++)
                            _legendRow(
                              t,
                              subColors[i % subColors.length],
                              data.subscriptionDistribution[i],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),

        _distributionCard(t, 'Người dùng theo vai trò', data.userDistribution),
        const SizedBox(height: 14),
        _distributionCard(t, 'Nội dung', data.contentTotals),
        const SizedBox(height: 14),
        _distributionCard(
          t,
          'Trạng thái thanh toán',
          data.paymentStatusDistribution,
        ),
      ],
    );
  }

  Widget _legendRow(AppTokens t, Color c, NamedValue v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            v.label,
            style: TextStyle(
              fontSize: 12,
              color: t.ink2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          vnd(v.value),
          style: TextStyle(
            fontSize: 12,
            color: t.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );

  Widget _distributionCard(AppTokens t, String title, List<NamedValue> items) {
    final max = items.isEmpty
        ? 1.0
        : items.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    return ThemedCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: t.ink,
            ),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text('Chưa có dữ liệu.', style: TextStyle(color: t.inkMuted))
          else
            ...items.map(
              (f) => HBar(
                label: f.label,
                valueText: compactNum(f.value),
                fraction: max == 0 ? 0 : f.value / max,
                color: t.primary,
                trackColor: t.surfaceSunken,
                labelColor: t.ink2,
              ),
            ),
        ],
      ),
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
