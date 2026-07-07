import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/themed_card.dart';
import '../../auth/providers/auth_provider.dart';

class AdminSettingsTab extends ConsumerWidget {
  const AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final name = ref.watch(authProvider).displayName ?? 'Quản trị viên';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // Profile
        ThemedCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: t.fabGradient,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: t.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: t.accentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Super admin',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: t.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        _group(t, 'Hệ thống', [
          _row(
            t,
            Icons.admin_panel_settings_outlined,
            'Phân quyền & vai trò',
            'Sắp có',
          ),
          _row(t, Icons.translate, 'Ngôn ngữ', 'Tiếng Việt'),
        ]),
        const SizedBox(height: 14),
        _group(t, 'Dữ liệu', [
          _row(
            t,
            Icons.file_download_outlined,
            'Xuất báo cáo',
            'CSV · PDF (sắp có)',
          ),
          _row(t, Icons.payments_outlined, 'Cổng thanh toán', 'PayOS'),
        ]),
        const SizedBox(height: 14),
        _group(t, 'Tài khoản', [
          InkWell(
            onTap: () => ref.read(authProvider.notifier).logout(),
            borderRadius: BorderRadius.circular(12),
            child: _rowContent(
              t,
              Icons.logout,
              'Đăng xuất',
              null,
              danger: true,
            ),
          ),
        ]),
      ],
    );
  }

  Widget _group(AppTokens t, String title, List<Widget> rows) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: t.inkMuted,
            letterSpacing: 0.3,
          ),
        ),
      ),
      ThemedCard(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(children: rows),
      ),
    ],
  );

  Widget _row(AppTokens t, IconData icon, String title, String? value) =>
      _rowContent(t, icon, title, value);

  Widget _rowContent(
    AppTokens t,
    IconData icon,
    String title,
    String? value, {
    bool danger = false,
  }) {
    final color = danger ? t.danger : t.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: danger ? t.danger : t.ink,
              ),
            ),
          ),
          if (value != null)
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: t.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (!danger) Icon(Icons.chevron_right, color: t.inkMuted, size: 20),
        ],
      ),
    );
  }
}
