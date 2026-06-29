import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/gradient_button.dart';
import '../providers/auth_provider.dart';

class EmailVerificationPendingPage extends ConsumerWidget {
  const EmailVerificationPendingPage({super.key, required this.email});

  final String email;

  Future<void> _resend(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(authProvider.notifier).resendVerification(email);
    if (!context.mounted) return;

    final message = ok
        ? 'Nếu email tồn tại và chưa được xác thực, Mascoteach đã gửi lại liên kết xác thực.'
        : (ref.read(authProvider).error ??
              'Không thể gửi lại email xác thực lúc này.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ok ? AppColors.brandBlue : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Xác thực email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 56,
                      color: AppColors.brandBlue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kiểm tra email của bạn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tài khoản của bạn đã được tạo. Mascoteach đã gửi một email xác thực. Vui lòng mở email đó trước khi đăng nhập.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.inkSecondary,
                        height: 1.5,
                      ),
                    ),
                    if (email.trim().isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBlue,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Email xác thực đã được gửi tới',
                              style: TextStyle(
                                color: AppColors.inkSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              email,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    GradientButton(
                      label: 'Đăng nhập ngay',
                      onPressed: () => context.go('/login'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: auth.loading ? null : () => _resend(context, ref),
                      child: auth.loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Gửi lại email xác thực'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Quay lại đăng nhập'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
