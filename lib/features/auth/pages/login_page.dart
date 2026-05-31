import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/decorative_blob.dart';
import '../../shared/widgets/google_button.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/mascot_avatar.dart';
import '../../shared/widgets/or_divider.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authProvider.notifier)
        .login(_emailCtl.text.trim(), _passCtl.text);
    if (!mounted) return;
    if (!ok) {
      final err = ref.read(authProvider).error ?? 'Đăng nhập thất bại';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _googleSignIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚧 Đăng nhập Google sẽ sớm có mặt'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Hero block: mascot + tiêu đề trên nền gradient
              _HeroHeader(),

              // Form card overlap lên hero
              Transform.translate(
                offset: const Offset(0, -36),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppShadows.hover,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GoogleButton(onPressed: _googleSignIn),
                          const SizedBox(height: 16),
                          const OrDivider(label: 'HOẶC ĐĂNG NHẬP VỚI EMAIL'),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailCtl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'ten@example.com',
                              prefixIcon: Icon(Icons.mail_outline,
                                  color: AppColors.inkMuted),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Nhập email';
                              }
                              if (!v.contains('@')) return 'Email không hợp lệ';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passCtl,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onSubmit(),
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: AppColors.inkMuted),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.inkMuted,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Tối thiểu 6 ký tự'
                                : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 8),
                                minimumSize: const Size(0, 36),
                              ),
                              child: const Text('Quên mật khẩu?'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GradientButton(
                            label: 'Đăng nhập',
                            loading: auth.loading,
                            onPressed: _onSubmit,
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms)
                      .moveY(
                          begin: 24,
                          end: 0,
                          curve: Curves.easeOutCubic,
                          duration: 500.ms),
                ),
              ),

              // Link "Đăng ký"
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản? ',
                        style: TextStyle(color: AppColors.inkSecondary)),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: const Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          color: AppColors.brandBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: DecorativeBlob(
                color: AppColors.brandLight,
                size: 200,
              ),
            ),
            Positioned(
              bottom: -20,
              left: -40,
              child: DecorativeBlob(
                color: AppColors.accentOrange,
                size: 160,
                duration: const Duration(seconds: 8),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MascotAvatar(
                      size: 100,
                      bgColor: Colors.white.withValues(alpha: 0.18),
                      showGlow: true,
                    ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                          begin: const Offset(0.6, 0.6),
                          end: const Offset(1, 1),
                        ),
                    const SizedBox(height: 14),
                    const Text(
                      'Chào mừng trở lại',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 500.ms)
                        .moveY(begin: 10, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      'Đăng nhập để tiếp tục học vui',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
