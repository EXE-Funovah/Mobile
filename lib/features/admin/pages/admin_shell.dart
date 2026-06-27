import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../providers/admin_providers.dart';
import 'admin_overview_tab.dart';
import 'admin_revenue_tab.dart';
import 'admin_accounts_tab.dart';
import 'admin_settings_tab.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _tab = 0;
  static const _titles = ['Tổng quan', 'Doanh thu', 'Tài khoản', 'Cài đặt'];

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    const pages = [
      AdminOverviewTab(),
      AdminRevenueTab(),
      AdminAccountsTab(),
      AdminSettingsTab(),
    ];

    return Scaffold(
      backgroundColor: t.appBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 14, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MASCOTEACH ADMIN',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: t.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _titles[_tab],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: t.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.notifications_none_rounded,
                    color: t.ink2,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: t.fabGradient,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: pages[_tab]),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: t.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Doanh thu',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Tài khoản',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}

/// Segmented thời gian 7N / 30N / 12T (dùng chung Tổng quan + Doanh thu).
class AdminRangeSegmented extends ConsumerWidget {
  const AdminRangeSegmented({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final range = ref.watch(adminRangeProvider);
    const opts = [('7d', '7 ngày'), ('30d', '30 ngày'), ('12m', '12 tháng')];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.surfaceSunken,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: opts.map((o) {
          final sel = range == o.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(adminRangeProvider.notifier).state = o.$1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? t.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  o.$2,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : t.ink2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
