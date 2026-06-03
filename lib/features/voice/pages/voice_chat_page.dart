import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

class VoiceChatPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  const VoiceChatPage({super.key, required this.onBack});

  @override
  ConsumerState<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends ConsumerState<VoiceChatPage>
    with SingleTickerProviderStateMixin {
  bool _listening = true;
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: t.heroGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                child: Row(
                  children: [
                    _CircleBtn(
                      icon: Icons.arrow_back_ios_new,
                      onTap: widget.onBack,
                    ),
                    const Spacer(),
                    const Column(
                      children: [
                        Text(
                          'Sumadi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Gia sư AI',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _CircleBtn(icon: Icons.bolt, onTap: () {}),
                  ],
                ),
              ),

              // Mascot + sonar rings
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_listening)
                              ...List.generate(3, (i) {
                                return Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.35,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                    )
                                    .animate(onPlay: (c) => c.repeat())
                                    .scale(
                                      duration: 2400.ms,
                                      delay: (i * 800).ms,
                                      begin: const Offset(0.45, 0.45),
                                      end: const Offset(1.4, 1.4),
                                      curve: Curves.easeOut,
                                    )
                                    .fadeOut(
                                      delay: (i * 800 + 1200).ms,
                                      duration: 1200.ms,
                                    );
                              }),
                            Container(
                              width: 158,
                              height: 158,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.25),
                                    Colors.white.withValues(alpha: 0.05),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x4D000000),
                                    blurRadius: 40,
                                    offset: Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child:
                                    Image.asset(
                                          'assets/images/mascot-speaking.png',
                                        )
                                        .animate(
                                          onPlay: (c) =>
                                              c.repeat(reverse: true),
                                        )
                                        .moveY(
                                          duration: 2600.ms,
                                          begin: 0,
                                          end: -6,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _listening ? 'Đang nghe…' : 'Sumadi đang nói…',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Waveform
                      SizedBox(
                        height: 40,
                        child: AnimatedBuilder(
                          animation: _ctl,
                          builder: (_, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(28, (i) {
                                final tick = _ctl.value * 10;
                                final h = _listening
                                    ? 6 + (sin(tick * 0.7 + i * 0.7).abs() * 30)
                                    : 5 + (sin(i.toDouble()).abs() * 8);
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1.5,
                                  ),
                                  width: 3,
                                  height: h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Transcripts
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(4),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x2E000000),
                                blurRadius: 14,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'Giải thích giúp mình quá trình nguyên phân với?',
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Được luôn! Nguyên phân gồm 4 kỳ chính: kỳ đầu, kỳ giữa, kỳ sau và kỳ cuối. Mình bắt đầu từ kỳ đầu nhé…',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Suggestion chips
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  children: ['Cho ví dụ', 'Giải thích lại', 'Tạo câu hỏi']
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              c,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              // Mic control
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SideBtn(icon: Icons.send_rounded, onTap: () {}),
                    GestureDetector(
                      onTap: () => setState(() => _listening = !_listening),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _listening ? Colors.white : t.accent,
                          boxShadow: [
                            BoxShadow(
                              color: _listening
                                  ? Colors.white.withValues(alpha: 0.18)
                                  : t.accent.withValues(alpha: 0.25),
                              blurRadius: 0,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.mic_rounded,
                          size: 32,
                          color: _listening ? t.primaryDeep : Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onBack,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: t.danger.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _SideBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SideBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
