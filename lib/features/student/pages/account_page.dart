import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../data/api/auth_api.dart';
import '../../../data/api/document_api.dart';
import '../../../data/api/user_api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_profile_provider.dart';
import '../../quiz/providers/documents_provider.dart';
import '../../shared/widgets/themed_card.dart';
import '../upload_gate.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final async = ref.watch(userProfileProvider);

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
          'Tài khoản',
          style: TextStyle(
            color: t.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorView(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
        data: (user) => _AccountBody(user: user),
      ),
    );
  }
}

class _AccountBody extends ConsumerWidget {
  final UserProfile user;
  const _AccountBody({required this.user});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    return '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final premium = isPremiumTier(user.subscriptionTier);
    // Đếm số tài liệu ACTIVE thật (không phải documentsProcessed tích luỹ).
    final docsUsed = ref.watch(documentsProvider).items.length;
    final pct = premium ? 1.0 : (docsUsed / kFreemiumDocLimit).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
      children: [
        // ============ Section 1: Thông tin cá nhân ============
        _sectionTitle(t, 'Thông tin cá nhân'),
        ThemedCard(
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.image_outlined,
                label: 'Ảnh đại diện',
                value: user.avatarUrl != null ? 'Đổi ảnh' : 'Thêm ảnh',
                onTap: () => _pickAndUploadAvatar(context, ref, user),
              ),
              _Divider(t),
              _SettingTile(
                icon: Icons.person_outline,
                label: 'Họ và tên',
                value: user.fullName,
                onTap: () => _showEditNameDialog(context, ref, user),
              ),
              _Divider(t),
              _SettingTile(
                icon: Icons.mail_outline,
                label: 'Email',
                value: user.email,
                trailingIcon: Icons.lock_outline,
              ),
              _Divider(t),
              _SettingTile(
                icon: Icons.shield_outlined,
                label: 'Vai trò',
                value: _roleVi(user.role),
                trailingIcon: null,
                disabled: true,
              ),
              _Divider(t),
              _SettingTile(
                icon: Icons.calendar_today_outlined,
                label: 'Tham gia',
                value: _formatDate(user.createdAt),
                trailingIcon: null,
                disabled: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ============ Section 2: Bảo mật ============
        _sectionTitle(t, 'Bảo mật'),
        ThemedCard(
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.lock_reset,
                label: 'Đổi mật khẩu',
                onTap: () => _confirmSendResetEmail(context, ref, user.email),
              ),
              _Divider(t),
              _SettingTile(
                icon: Icons.link,
                label: 'Tài khoản Google',
                value:
                    (user.authenticator == 'Google' ||
                        user.authenticator == 'Both')
                    ? 'Đã liên kết'
                    : 'Chưa liên kết',
                trailingIcon: null,
                disabled: true,
              ),
              _Divider(t),
              _SettingTile(
                icon: Icons.devices_outlined,
                label: 'Đăng xuất khỏi thiết bị khác',
                value: 'Sắp ra mắt',
                disabled: true,
              ),
              _Divider(t),
              _SettingTile(
                icon: Icons.security,
                label: 'Bật xác thực 2 bước (2FA)',
                value: 'Sắp ra mắt',
                disabled: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ============ Section 3: Gói dịch vụ ============
        _sectionTitle(t, 'Gói dịch vụ'),
        ThemedCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: user.subscriptionTier == 'Premium'
                          ? t.accentSoft
                          : t.surfaceSunken,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      user.subscriptionTier == 'Premium'
                          ? '💎 Premium'
                          : 'Freemium',
                      style: TextStyle(
                        color: user.subscriptionTier == 'Premium'
                            ? t.accent
                            : t.ink2,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    premium
                        ? 'Không giới hạn'
                        : '$docsUsed / $kFreemiumDocLimit tài liệu',
                    style: TextStyle(
                      color: t.inkMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 8,
                  child: Stack(
                    children: [
                      Container(color: t.surfaceSunken),
                      FractionallySizedBox(
                        widthFactor: pct,
                        child: Container(
                          color: pct >= 0.9 ? t.danger : t.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ThemedCard(
          child: Column(
            children: [
              _SettingTile(
                icon: Icons.workspace_premium,
                label: 'Nâng cấp lên Premium',
                onTap: () => context.push('/student/pricing'),
              ),
              _Divider(t),
              _SettingTile(
                icon: Icons.receipt_long,
                label: 'Lịch sử thanh toán',
                value: 'Sắp ra mắt',
                disabled: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ============ Section 4: Vùng nguy hiểm ============
        _sectionTitle(t, 'Vùng nguy hiểm', danger: true),
        ThemedCard(
          child: _SettingTile(
            icon: Icons.delete_forever,
            label: 'Xóa tài khoản',
            danger: true,
            onTap: () => _confirmDeleteAccount(context, ref, user.id),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionTitle(AppTokens t, String text, {bool danger = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: danger ? t.danger : t.inkMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  String _roleVi(String r) {
    switch (r.toLowerCase()) {
      case 'student':
        return 'Học sinh';
      case 'teacher':
        return 'Giáo viên';
      case 'parent':
        return 'Phụ huynh';
      default:
        return r;
    }
  }

  static String _imageContentType(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  /// Chọn ảnh → presign → PUT S3 → PATCH avatar → refresh profile.
  Future<void> _pickAndUploadAvatar(
    BuildContext context,
    WidgetRef ref,
    UserProfile u,
  ) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes =
        file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final ct = _imageContentType(file.name);
      final presign = await UserApi.instance.avatarUploadUrl(
        fileName: file.name,
        contentType: ct,
      );
      await DocumentApi.instance.putToS3(
        uploadUrl: presign.uploadUrl,
        contentType: ct,
        bytes: bytes,
      );
      await UserApi.instance.updateAvatar(presign.s3Key);
      ref.invalidate(userProfileProvider);
      if (context.mounted) Navigator.pop(context); // đóng loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật ảnh đại diện')),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, UserProfile u) {
    final ctl = TextEditingController(text: u.fullName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi họ tên'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Họ và tên'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final newName = ctl.text.trim();
              if (newName.isEmpty || newName == u.fullName) {
                Navigator.pop(ctx);
                return;
              }
              try {
                await UserApi.instance.update(
                  id: u.id,
                  fullName: newName,
                  email: u.email,
                  role: u.role,
                  subscriptionTier: u.subscriptionTier,
                );
                ref.invalidate(userProfileProvider);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật tên')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(
                    ctx,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmSendResetEmail(
    BuildContext context,
    WidgetRef ref,
    String email,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Text(
          'Hệ thống sẽ gửi liên kết đặt lại mật khẩu tới $email. Tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await AuthApi.instance.forgotPassword(email: email);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã gửi email. Kiểm tra hộp thư của bạn.'),
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(
                    ctx,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref, int userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: const Text(
          'Toàn bộ tài liệu và bộ câu hỏi của bạn sẽ bị xóa. '
          'Hành động này KHÔNG thể hoàn tác.\n\n'
          'Bạn có chắc chắn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              try {
                await UserApi.instance.delete(userId);
                await ref.read(authProvider.notifier).logout();
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(
                    ctx,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final IconData? trailingIcon;
  final bool disabled;
  final bool danger;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.label,
    this.value,
    this.trailingIcon = Icons.chevron_right,
    this.disabled = false,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final t = ref.watch(themeProvider);
        final color = danger ? t.danger : t.ink;
        final iconColor = disabled ? t.inkMuted : (danger ? t.danger : t.ink2);
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
                        : (danger
                              ? t.danger.withValues(alpha: 0.1)
                              : t.surfaceSunken),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 19, color: iconColor),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: disabled ? t.inkMuted : color,
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
      },
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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
