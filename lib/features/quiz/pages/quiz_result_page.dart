import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../shared/widgets/ring.dart';
import '../../shared/widgets/themed_card.dart';

class QuizResultPage extends ConsumerWidget {
  final int score;
  final int total;
  const QuizResultPage({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final pct = score / total;
    final xp = score * 10 + (pct == 1 ? 50 : 0);
    final stars = pct >= 0.9
        ? 3
        : pct >= 0.6
        ? 2
        : pct > 0
        ? 1
        : 0;
    final praise = pct == 1
        ? 'Tuyệt đối! 🎉'
        : pct >= 0.8
        ? 'Xuất sắc!'
        : pct >= 0.6
        ? 'Làm tốt lắm!'
        : pct > 0
        ? 'Cố lên nhé!'
        : 'Thử lại nào!';

    final confettiColors = [t.primary, t.accent, t.ok, t.tintInks[3]];

    return Scaffold(
      backgroundColor: t.appBg,
      body: Stack(
        children: [
          // Confetti
          IgnorePointer(
            child: Stack(
              children: List.generate(
                22,
                (k) => _Confetti(
                  index: k,
                  color: confettiColors[k % confettiColors.length],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
                    child: Column(
                      children: [
                        // Mascot + stars
                        SizedBox(
                          width: 170,
                          height: 158,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                bottom: 6,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        t.primarySoft,
                                        Colors.transparent,
                                      ],
                                      stops: const [0, 0.7],
                                    ),
                                  ),
                                ),
                              ),
                              Image.asset(
                                    'assets/images/main-mascot-full.png',
                                    width: 150,
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .moveY(duration: 2600.ms, begin: 0, end: -8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (s) {
                            final lit = s < stars;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Transform.translate(
                                offset: Offset(0, s == 1 ? -6 : 0),
                                child: Transform.scale(
                                  scale: s == 1 ? 1.18 : 1,
                                  child:
                                      Icon(
                                            Icons.star_rounded,
                                            size: s == 1 ? 40 : 34,
                                            color: lit
                                                ? t.accent
                                                : t.surfaceSunken,
                                          )
                                          .animate(target: lit ? 1 : 0)
                                          .scale(
                                            duration: 500.ms,
                                            delay: (200 + s * 150).ms,
                                            begin: const Offset(0.2, 0.2),
                                            end: const Offset(1, 1),
                                            curve: Curves.easeOutBack,
                                          ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          praise,
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: t.displayWeight,
                            color: t.ink,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Bạn đã hoàn thành ',
                                style: TextStyle(color: t.ink2),
                              ),
                              TextSpan(
                                text: 'Tế bào & cấu trúc',
                                style: TextStyle(
                                  color: t.ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // Ring
                        const SizedBox(height: 20),
                        Ring(
                          pct: pct,
                          size: 130,
                          stroke: 12,
                          color: t.primary,
                          track: t.surfaceSunken,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(height: 1),
                                  children: [
                                    TextSpan(
                                      text: '$score',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w900,
                                        color: t.ink,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/$total',
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: t.inkMuted,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${(pct * 100).round()}% đúng',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: t.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        // 3 stat tiles
                        Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                icon: Icons.bolt,
                                value: '+$xp',
                                label: 'điểm XP',
                                tint: 1,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: _StatTile(
                                icon: Icons.check_rounded,
                                value: '$score',
                                label: 'câu đúng',
                                tint: 2,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: _StatTile(
                                icon: Icons.local_fire_department,
                                value: '8',
                                label: 'ngày streak',
                                tint: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/student'),
                        child: Container(
                          width: double.infinity,
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
                            children: const [
                              Text(
                                'Tiếp tục học',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => context.go('/student/quiz'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: t.surface,
                            side: BorderSide(color: t.line),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Làm lại',
                            style: TextStyle(
                              color: t.ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends ConsumerWidget {
  final IconData icon;
  final String value;
  final String label;
  final int tint;
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return ThemedCard(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: t.tintInks[tint], size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: t.ink,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: t.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Confetti extends StatefulWidget {
  final int index;
  final Color color;
  const _Confetti({required this.index, required this.color});

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final double _left;
  late final bool _round;
  late final double _sz;

  @override
  void initState() {
    super.initState();
    final r = Random(widget.index);
    _left = ((widget.index * 4.5 + 4) % 100) / 100;
    _round = widget.index % 3 != 0;
    _sz = widget.index % 2 == 1 ? 7 : 9;
    final dur = 2400 + (widget.index % 5) * 400;
    _ctl = AnimationController(
      duration: Duration(milliseconds: dur),
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: (widget.index % 7) * 250), () {
      if (mounted) _ctl.repeat();
    });
    _ = r;
  }

  // ignore: unused_field
  dynamic _;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, _) {
        return Positioned(
          left: MediaQuery.of(context).size.width * _left,
          top: -16 + _ctl.value * (h + 32),
          child: Transform.rotate(
            angle: _ctl.value * 6.28,
            child: Container(
              width: _sz,
              height: _sz,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(_round ? 999 : 2),
              ),
            ),
          ),
        );
      },
    );
  }
}
