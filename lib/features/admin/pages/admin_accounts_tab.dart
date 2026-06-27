import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/themed_card.dart';
import '../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../utils/admin_format.dart';

class AdminAccountsTab extends ConsumerStatefulWidget {
  const AdminAccountsTab({super.key});

  @override
  ConsumerState<AdminAccountsTab> createState() => _AdminAccountsTabState();
}

class _AdminAccountsTabState extends ConsumerState<AdminAccountsTab> {
  final _searchCtl = TextEditingController();

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    final async = ref.watch(adminAccountsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      children: [
        // Search
        Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: t.line),
          ),
          child: TextField(
            controller: _searchCtl,
            onSubmitted: (v) =>
                ref.read(adminAccountSearchProvider.notifier).state = v.trim(),
            style: TextStyle(color: t.ink, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Tìm theo tên / email…',
              hintStyle: TextStyle(color: t.inkMuted),
              prefixIcon: Icon(Icons.search, color: t.inkMuted, size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
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
                  onPressed: () => ref.invalidate(adminAccountsProvider),
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
  final AdminAccounts d;
  const _Body({required this.t, required this.d});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summary(t, 'Tổng tài khoản', vnd(d.totalAccounts), t.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summary(
                t,
                'Đang trả phí',
                vnd(d.payingAccounts),
                t.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Theo mức sử dụng (${d.total})',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: t.ink2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (d.items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text(
              'Không có tài khoản nào.',
              style: TextStyle(color: t.inkMuted),
            ),
          )
        else
          ...d.items.map((a) => _AccountCard(t: t, a: a)),
      ],
    );
  }

  Widget _summary(AppTokens t, String label, String value, Color color) =>
      ThemedCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: t.inkMuted,
              ),
            ),
          ],
        ),
      );
}

class _AccountCard extends StatelessWidget {
  final AppTokens t;
  final AdminAccount a;
  const _AccountCard({required this.t, required this.a});

  @override
  Widget build(BuildContext context) {
    final initials = a.name.trim().isEmpty
        ? '?'
        : a.name
              .trim()
              .split(RegExp(r'\s+'))
              .map((e) => e[0])
              .take(2)
              .join()
              .toUpperCase();
    final (statusLabel, statusColor) = switch (a.status) {
      'on' => ('Hoạt động', t.ok),
      'trial' => ('Dùng thử', t.accent),
      _ => ('Ít dùng', t.inkMuted),
    };
    final isPremium = a.plan.toLowerCase().contains('premium');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ThemedCard(
        padding: const EdgeInsets.all(13),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: t.primarySoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: t.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                        ),
                      ),
                      Text(
                        a.type,
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
                    color: isPremium ? t.accentSoft : t.surfaceSunken,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    a.plan,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: isPremium ? t.accent : t.ink2,
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
                _stat(
                  t,
                  Icons.auto_awesome,
                  compactNum(a.questions),
                  'câu hỏi',
                ),
                const SizedBox(width: 18),
                _stat(t, Icons.mic, '${a.minutes}', 'phút'),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(AppTokens t, IconData icon, String value, String label) => Row(
    children: [
      Icon(icon, size: 15, color: t.inkMuted),
      const SizedBox(width: 5),
      Text(
        value,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: t.ink,
        ),
      ),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontSize: 11, color: t.inkMuted)),
    ],
  );
}
