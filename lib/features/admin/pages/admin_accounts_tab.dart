import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/themed_card.dart';
import '../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../utils/admin_format.dart';
import '../widgets/admin_ui.dart';
import 'admin_user_detail_screen.dart';

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
    final async = ref.watch(adminUsersProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      children: [
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
        const SizedBox(height: 12),
        AdminChips(
          t: t,
          labels: const ['Mọi vai trò', 'Giáo viên', 'Học sinh', 'Phụ huynh', 'Admin'],
          values: const [null, 'Teacher', 'Student', 'Parent', 'Admin'],
          selected: ref.watch(adminUserRoleProvider),
          onSelect: (v) => ref.read(adminUserRoleProvider.notifier).state = v,
        ),
        const SizedBox(height: 8),
        AdminChips(
          t: t,
          labels: const ['Mọi gói', 'Freemium', 'Premium', 'Hết hạn'],
          values: const [null, 'Freemium', 'Premium', 'Expired'],
          selected: ref.watch(adminUserSubProvider),
          onSelect: (v) => ref.read(adminUserSubProvider.notifier).state = v,
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
                  onPressed: () => ref.invalidate(adminUsersProvider),
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
  final AdminUsers d;
  const _Body({required this.t, required this.d});

  @override
  Widget build(BuildContext context) {
    final premiumInPage = d.items
        .where((u) => u.subscriptionStatus == 'Premium')
        .length;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summary(t, 'Tổng tài khoản', vnd(d.total), t.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summary(
                t,
                'Premium (trang này)',
                vnd(premiumInPage),
                t.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Danh sách (${d.items.length}/${d.total})',
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
          ...d.items.map((u) => _UserCard(t: t, u: u)),
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

class _UserCard extends StatelessWidget {
  final AppTokens t;
  final AdminUserItem u;
  const _UserCard({required this.t, required this.u});

  @override
  Widget build(BuildContext context) {
    final initials = u.fullName.trim().isEmpty
        ? '?'
        : u.fullName
              .trim()
              .split(RegExp(r'\s+'))
              .map((e) => e[0])
              .take(2)
              .join()
              .toUpperCase();
    final (subLabel, subColor) = switch (u.subscriptionStatus) {
      'Premium' => ('Premium', t.accent),
      'Expired' => ('Hết hạn', t.danger),
      _ => ('Freemium', t.inkMuted),
    };
    final roleLabel = switch (u.role) {
      'Teacher' => 'Giáo viên',
      'Student' => 'Học sinh',
      'Parent' => 'Phụ huynh',
      'Admin' => 'Admin',
      _ => u.role,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ThemedCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdminUserDetailScreen(userId: u.id),
          ),
        ),
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
                        u.fullName.isEmpty ? 'Chưa đặt tên' : u.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                        ),
                      ),
                      Text(
                        u.email,
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
                    color: subColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    subLabel,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: subColor,
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
                _tag(t, roleLabel),
                const SizedBox(width: 14),
                _stat(t, Icons.description_outlined, u.documentCount, 'TL'),
                const SizedBox(width: 12),
                _stat(t, Icons.quiz_outlined, u.quizCount, 'Quiz'),
                const SizedBox(width: 12),
                _stat(t, Icons.layers_outlined, u.flashcardCount, 'Thẻ'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(AppTokens t, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: t.surfaceSunken,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: t.ink2,
      ),
    ),
  );

  Widget _stat(AppTokens t, IconData icon, int value, String label) => Row(
    children: [
      Icon(icon, size: 15, color: t.inkMuted),
      const SizedBox(width: 4),
      Text(
        '$value',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: t.ink,
        ),
      ),
      const SizedBox(width: 2),
      Text(label, style: TextStyle(fontSize: 10.5, color: t.inkMuted)),
    ],
  );
}
