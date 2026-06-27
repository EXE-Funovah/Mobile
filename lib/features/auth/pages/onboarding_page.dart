import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/theme_provider.dart';
import '../../shared/widgets/google_button.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step = 0;

  final _slides = const [
    (
      img: 'assets/images/main-mascot-full.png',
      big: 'Học bằng giọng nói',
      sub:
          'Trò chuyện trực tiếp với Sumadi — hỏi gì cũng được, như có gia sư riêng bên cạnh.',
    ),
    (
      img: 'assets/images/main-mascot-full.png',
      big: 'Tài liệu thành câu hỏi',
      sub:
          'Tải lên bài học, Sumadi biến nó thành bộ câu trắc nghiệm để bạn ôn thật nhanh.',
    ),
    (
      img: 'assets/images/mascot-head.png',
      big: 'Học đều mỗi ngày',
      sub:
          'Giữ chuỗi streak, ghi điểm XP và lên cấp cùng người bạn nhỏ của bạn.',
    ),
  ];

  Future<void> _done() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('onboarded', true);
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    final s = _slides[_step];
    final last = _step == _slides.length - 1;

    return Scaffold(
      backgroundColor: t.appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 6, 26, 22),
          child: Stack(
            children: [
              // Decorative blobs
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.primarySoft.withValues(alpha: t.isDark ? 0.5 : 1),
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                left: -60,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.accentSoft.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: t.fabGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mascoteach',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                        ),
                      ),
                      const Spacer(),
                      if (!last)
                        TextButton(
                          onPressed: _done,
                          child: Text(
                            'Bỏ qua',
                            style: TextStyle(
                              color: t.inkMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 230,
                          height: 230,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [t.primarySoft, Colors.transparent],
                              stops: const [0, 0.7],
                            ),
                          ),
                          alignment: Alignment.center,
                          child:
                              Image.asset(
                                    s.img,
                                    width: 200,
                                    key: ValueKey(_step),
                                  )
                                  .animate(key: ValueKey(_step))
                                  .scale(
                                    duration: 500.ms,
                                    curve: Curves.easeOutBack,
                                    begin: const Offset(0.6, 0.6),
                                    end: const Offset(1, 1),
                                  )
                                  .fadeIn(),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          s.big,
                          key: ValueKey('big-$_step'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: t.displayWeight,
                            color: t.ink,
                            letterSpacing: -0.5,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 290,
                          child: Text(
                            s.sub,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: t.ink2,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // dots
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        final on = i == _step;
                        return GestureDetector(
                          onTap: () => setState(() => _step = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: on ? 22 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: on ? t.primary : t.inkMuted,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // CTAs
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () => last ? _done() : setState(() => _step++),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: t.fabGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: t.fabRing,
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                last ? 'Bắt đầu học' : 'Tiếp tục',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 11),
                      GoogleButton(
                        label: 'Đăng nhập với Google',
                        onPressed: _done,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
