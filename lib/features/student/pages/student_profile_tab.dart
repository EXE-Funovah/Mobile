import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../data/models/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/themed_card.dart';

class StudentProfileTab extends ConsumerWidget {
  const StudentProfileTab({super.key});

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Học sinh';
      case UserRole.teacher:
        return 'Giáo viên';
      case UserRole.parent:
        return 'Phụ huynh';
      case UserRole.unknown:
        return 'Người dùng';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final auth = ref.watch(authProvider);
    final name = auth.displayName ?? 'Học sinh';
    final roleLabel = _roleLabel(auth.role);
    // TODO(gamification): thay 0 bằng UserStats khi BE sẵn sàng.
    final stats = const [
      (i: Icons.local_fire_department, v: '0', l: 'ngày streak', tint: 1),
      (i: Icons.gps_fixed, v: '0', l: 'câu đúng', tint: 2),
      (i: Icons.access_time, v: '0h', l: 'đã học', tint: 0),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
      children: [
        // Header
        Column(
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                gradient: t.fabGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: t.fabRing,
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'M',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              name,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: t.ink,
              ),
            ),
            Text(
              roleLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.inkMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Stats
        Row(
          children: stats.map((s) {
            final index = stats.indexOf(s);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < stats.length - 1 ? 11 : 0,
                ),
                child: ThemedCard(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    children: [
                      Icon(s.i, color: t.tintInks[s.tint], size: 22),
                      const SizedBox(height: 7),
                      Text(
                        s.v,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.l,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: t.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // XP bar — placeholder, sẽ nối /api/UserStats/me
        ThemedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cấp 1',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: t.ink,
                    ),
                  ),
                  Text(
                    '0 / 2.000 XP',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: t.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 9,
                  child: Stack(
                    children: [
                      Container(color: t.surfaceSunken),
                      FractionallySizedBox(
                        widthFactor: 0,
                        child: Container(
                          decoration: BoxDecoration(gradient: t.fabGradient),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Settings card
        ThemedCard(
          child: Column(
            children: [
              _tile(
                t,
                Icons.person_outline,
                'Tài khoản',
                null,
                () => context.push('/student/account'),
              ),
              Divider(color: t.line, height: 1),
              _tile(
                t,
                Icons.notifications_outlined,
                'Thông báo',
                'Sắp ra mắt',
                () {},
              ),
              Divider(color: t.line, height: 1),
              _tile(t, Icons.language, 'Ngôn ngữ', 'Tiếng Việt', () {}),
              Divider(color: t.line, height: 1),
              _themeRow(context, ref, t),
              Divider(color: t.line, height: 1),
              _tile(
                t,
                Icons.settings_outlined,
                'Cài đặt',
                null,
                () => context.push('/student/settings'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Logout
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide(color: t.line),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Đăng xuất',
              style: TextStyle(
                color: t.danger,
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tile(
    AppTokens t,
    IconData icon,
    String label,
    String? meta,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: t.surfaceSunken,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: t.ink2, size: 19),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: t.ink,
                ),
              ),
            ),
            if (meta != null)
              Text(
                meta,
                style: TextStyle(
                  fontSize: 13,
                  color: t.inkMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            Icon(Icons.chevron_right, color: t.inkMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _themeRow(BuildContext context, WidgetRef ref, AppTokens t) {
    final isDark = t.isDark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.surfaceSunken,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: t.ink2,
              size: 19,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              'Giao diện',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: t.ink,
              ),
            ),
          ),
          // Segmented toggle
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: t.surfaceSunken,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _segBtn(context, ref, 'Sáng', AppMode.clean, !isDark, t),
                _segBtn(context, ref, 'Tối', AppMode.gameShow, isDark, t),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _segBtn(
    BuildContext context,
    WidgetRef ref,
    String label,
    AppMode mode,
    bool active,
    AppTokens t,
  ) {
    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).setMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? t.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : t.inkMuted,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
