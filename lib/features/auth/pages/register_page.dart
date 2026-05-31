import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/google_button.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/or_divider.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String _role = 'Student';
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).register(
          fullName: _name.text.trim(),
          email: _email.text.trim(),
          password: _pass.text,
          role: _role,
        );
    if (!mounted) return;
    if (!ok) {
      final err = ref.read(authProvider).error ?? 'Đăng ký thất bại';
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

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider).loading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tạo tài khoản',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tham gia cộng đồng Mascoteach ngay hôm nay',
                  style: TextStyle(color: AppColors.inkSecondary),
                ),
                const SizedBox(height: 24),
                GoogleButton(
                  label: 'Đăng ký với Google',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🚧 Đăng ký Google sẽ sớm có'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const OrDivider(label: 'HOẶC ĐIỀN THÔNG TIN'),
                const SizedBox(height: 16),
                _RoleSelector(
                  selected: _role,
                  onChanged: (v) => setState(() => _role = v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    hintText: 'Nguyễn Văn A',
                    prefixIcon: Icon(Icons.person_outline,
                        color: AppColors.inkMuted),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nhập họ tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'ten@example.com',
                    prefixIcon:
                        Icon(Icons.mail_outline, color: AppColors.inkMuted),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Nhập email';
                    if (!v.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pass,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    hintText: 'Tối thiểu 6 ký tự',
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: AppColors.inkMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.inkMuted,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Tối thiểu 6 ký tự' : null,
                ),
                const SizedBox(height: 24),
                GradientButton(
                  label: 'Tạo tài khoản',
                  loading: loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                          color: AppColors.inkMuted, fontSize: 12),
                      children: [
                        const TextSpan(text: 'Bằng cách đăng ký, bạn đồng ý với '),
                        TextSpan(
                          text: 'Điều khoản',
                          style: TextStyle(
                            color: AppColors.brandBlue.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' của Mascoteach'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .moveY(begin: 16, end: 0, curve: Curves.easeOut),
          ),
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _RoleSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final roles = const [
      ('Student', 'Học sinh', Icons.school, AppColors.brandBlue),
      ('Teacher', 'Giáo viên', Icons.cast_for_education, AppColors.accentOrange),
      ('Parent', 'Phụ huynh', Icons.family_restroom, AppColors.accentEmerald),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Tôi là',
            style: TextStyle(
              color: AppColors.inkSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        Row(
          children: roles.map((r) {
            final isSelected = selected == r.$1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: r == roles.last ? 0 : 8),
                child: GestureDetector(
                  onTap: () => onChanged(r.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? r.$4.withValues(alpha: 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? r.$4 : AppColors.border,
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(r.$3,
                            color: isSelected ? r.$4 : AppColors.inkMuted,
                            size: 26),
                        const SizedBox(height: 6),
                        Text(
                          r.$2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected ? AppColors.ink : AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
