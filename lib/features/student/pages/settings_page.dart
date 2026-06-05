import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/themed_card.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _version = '—';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = 'v${info.version}+${info.buildNumber}');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    final s = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: t.appBg,
      appBar: AppBar(
        backgroundColor: t.appBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: t.ink),
        ),
        title: Text(
          'Cài đặt',
          style: TextStyle(
            color: t.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        children: [
          // ============ Section 1: Học tập ============
          _sectionTitle(t, 'Học tập'),
          ThemedCard(
            child: Column(
              children: [
                _GoalSliderTile(
                  minutes: s.dailyGoalMinutes,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setDailyGoal(v),
                ),
                _Divider(t),
                _futureTile(Icons.alarm, 'Nhắc nhở học mỗi ngày'),
                _Divider(t),
                _futureTile(Icons.pause_circle_outline, 'Tự dừng khi rời màn'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ============ Section 2: Âm thanh & Cảm giác ============
          _sectionTitle(t, 'Âm thanh & Cảm giác'),
          ThemedCard(
            child: Column(
              children: [
                _SwitchTile(
                  icon: Icons.volume_up_outlined,
                  label: 'Hiệu ứng âm thanh',
                  value: s.soundEnabled,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setSound(v),
                ),
                _Divider(t),
                _SwitchTile(
                  icon: Icons.vibration,
                  label: 'Rung phản hồi',
                  value: s.hapticEnabled,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setHaptic(v),
                ),
                _Divider(t),
                _futureTile(Icons.record_voice_over, 'Giọng đọc Sumadi'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ============ Section 3: Thông báo ============
          _sectionTitle(t, 'Thông báo'),
          ThemedCard(
            child: Column(
              children: [
                _futureTile(Icons.notifications_outlined, 'Thông báo đẩy'),
                _Divider(t),
                _futureTile(
                  Icons.local_fire_department,
                  'Cảnh báo streak sắp đứt',
                ),
                _Divider(t),
                _futureTile(Icons.mail_outline, 'Email nhắc học'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ============ Section 4: Dữ liệu & Bộ nhớ ============
          _sectionTitle(t, 'Dữ liệu & Bộ nhớ'),
          ThemedCard(
            child: Column(
              children: [
                _SettingTile(
                  icon: Icons.cleaning_services_outlined,
                  label: 'Xóa bộ nhớ đệm',
                  onTap: () => _confirmClearCache(context),
                ),
                _Divider(t),
                _futureTile(Icons.wifi, 'Chỉ tải khi có WiFi'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ============ Section 5: Riêng tư ============
          _sectionTitle(t, 'Riêng tư'),
          ThemedCard(
            child: Column(
              children: [
                _SwitchTile(
                  icon: Icons.analytics_outlined,
                  label: 'Chia sẻ thống kê ẩn danh',
                  value: s.analyticsEnabled,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setAnalytics(v),
                ),
                _Divider(t),
                _futureTile(Icons.download_outlined, 'Xuất dữ liệu học tập'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ============ Section 6: Về ứng dụng ============
          _sectionTitle(t, 'Về ứng dụng'),
          ThemedCard(
            child: Column(
              children: [
                _SettingTile(
                  icon: Icons.info_outline,
                  label: 'Phiên bản',
                  value: _version,
                  trailingIcon: null,
                ),
                _Divider(t),
                _SettingTile(
                  icon: Icons.description_outlined,
                  label: 'Điều khoản dịch vụ',
                  onTap: () => _openUrl('https://mascoteach.com/terms'),
                ),
                _Divider(t),
                _SettingTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Chính sách bảo mật',
                  onTap: () => _openUrl('https://mascoteach.com/privacy'),
                ),
                _Divider(t),
                _SettingTile(
                  icon: Icons.code,
                  label: 'Giấy phép mã nguồn mở',
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'Mascoteach',
                  ),
                ),
                _Divider(t),
                _SettingTile(
                  icon: Icons.support_agent,
                  label: 'Liên hệ hỗ trợ',
                  onTap: () => _openUrl('mailto:support@mascoteach.com'),
                ),
                _Divider(t),
                _SettingTile(
                  icon: Icons.bug_report_outlined,
                  label: 'Gửi báo lỗi',
                  onTap: () => _openUrl(
                    'mailto:support@mascoteach.com?subject=Báo lỗi Mobile $_version',
                  ),
                ),
                _Divider(t),
                _futureTile(Icons.system_update_alt, 'Kiểm tra cập nhật'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(AppTokens t, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: t.inkMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _futureTile(IconData icon, String label) {
    return _SettingTile(
      icon: icon,
      label: label,
      value: 'Sắp ra mắt',
      disabled: true,
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bộ nhớ đệm?'),
        content: const Text(
          'Tài liệu và ảnh đã tải về sẽ bị xóa khỏi máy. '
          'Lần sau cần tải lại từ máy chủ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa bộ nhớ đệm')),
                );
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

// ============== Tile widgets ==============

class _GoalSliderTile extends ConsumerWidget {
  final int minutes;
  final ValueChanged<int> onChanged;
  const _GoalSliderTile({required this.minutes, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: t.surfaceSunken,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.gps_fixed, color: t.ink2, size: 19),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  'Mục tiêu hàng ngày',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: t.ink,
                  ),
                ),
              ),
              Text(
                '$minutes phút',
                style: TextStyle(
                  color: t.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Slider(
            value: minutes.toDouble(),
            min: 10,
            max: 60,
            divisions: 10,
            label: '$minutes phút',
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends ConsumerWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.surfaceSunken,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: t.ink2),
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
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingTile extends ConsumerWidget {
  final IconData icon;
  final String label;
  final String? value;
  final IconData? trailingIcon;
  final bool disabled;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.label,
    this.value,
    this.trailingIcon = Icons.chevron_right,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: disabled
                    ? t.surfaceSunken.withValues(alpha: 0.5)
                    : t.surfaceSunken,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 19,
                color: disabled ? t.inkMuted : t.ink2,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: disabled ? t.inkMuted : t.ink,
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value!,
                style: TextStyle(
                  fontSize: 13,
                  color: t.inkMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailingIcon != null) const SizedBox(width: 4),
            ],
            if (trailingIcon != null && !disabled)
              Icon(trailingIcon, color: t.inkMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final AppTokens t;
  const _Divider(this.t);
  @override
  Widget build(BuildContext context) =>
      Divider(color: t.line, height: 1, indent: 16, endIndent: 16);
}
