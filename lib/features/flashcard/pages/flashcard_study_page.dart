import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/ring.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_providers.dart';

/// Học lật thẻ (active recall): lật từng thẻ, tự đánh giá "Đã thuộc"/"Cần ôn
/// lại", đến hết bộ → màn kết thúc. KHÔNG chấm điểm/XP/streak.
class FlashcardStudyPage extends ConsumerStatefulWidget {
  final int quizId;
  final String title;
  const FlashcardStudyPage({super.key, required this.quizId, required this.title});

  @override
  ConsumerState<FlashcardStudyPage> createState() => _FlashcardStudyPageState();
}

class _FlashcardStudyPageState extends ConsumerState<FlashcardStudyPage> {
  List<FlashCard> _all = const [];
  List<FlashCard> _cards = const [];
  bool _loading = true;
  String? _error;

  int _i = 0;
  bool _flipped = false;
  final Map<int, String> _marks = {}; // idx -> 'known' | 'review'
  FlashcardResult? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cards = await ref.read(
        flashcardStudyProvider(widget.quizId).future,
      );
      if (!mounted) return;
      setState(() {
        _all = cards;
        _cards = cards;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _advance(String mark) {
    _marks[_i] = mark;
    if (_i >= _cards.length - 1) {
      final known = _marks.values.where((m) => m == 'known').length;
      final review = _marks.values.where((m) => m == 'review').length;
      // Lưu tiến độ "đã thuộc" cục bộ để Thư viện hiển thị.
      FlashcardProgress.setLearned(widget.quizId, known);
      ref.invalidate(flashcardSetsProvider);
      setState(() => _result = FlashcardResult(
            total: _cards.length,
            known: known,
            review: review,
          ));
    } else {
      setState(() {
        _flipped = false;
        _i++;
      });
    }
  }

  void _prev() {
    if (_i > 0) {
      setState(() {
        _flipped = false;
        _i--;
      });
    }
  }

  void _restart(List<FlashCard> cards) {
    setState(() {
      _cards = cards;
      _i = 0;
      _flipped = false;
      _marks.clear();
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: t.appBg,
      body: SafeArea(child: _body(t)),
    );
  }

  Widget _body(AppTokens t) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 44, color: t.danger),
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.ink2),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    if (_cards.isEmpty) {
      return Center(
        child: Text(
          'Bộ thẻ này chưa có thẻ nào.',
          style: TextStyle(color: t.ink2, fontWeight: FontWeight.w600),
        ),
      );
    }
    if (_result != null) return _doneView(t, _result!);
    return _studyView(t);
  }

  // ───────────────────────── STUDY ─────────────────────────
  Widget _studyView(AppTokens t) {
    final total = _cards.length;
    final progress = (_i + (_flipped ? 1 : 0.5)) / total;
    return Column(
      children: [
        // top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.surfaceSunken,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.close_rounded, size: 20, color: t.ink2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    builder: (ctx, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 10,
                      backgroundColor: t.surfaceSunken,
                      valueColor: AlwaysStoppedAnimation(t.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: t.cardBorder,
                  boxShadow: t.cardShadow,
                ),
                child: Row(
                  children: [
                    Icon(Icons.layers_outlined, size: 15, color: t.primary),
                    const SizedBox(width: 5),
                    Text(
                      '${_i + 1}/$total',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: t.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
            child: _FlipCard(
              key: ValueKey(_i),
              card: _cards[_i],
              flipped: _flipped,
              onFlip: () => setState(() => _flipped = !_flipped),
              t: t,
            ),
          ),
        ),
        // bottom controls
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
          child: _flipped ? _gradeControls(t) : _flipControls(t),
        ),
      ],
    );
  }

  Widget _flipControls(AppTokens t) {
    return Row(
      children: [
        GestureDetector(
          onTap: _i == 0 ? null : _prev,
          child: Opacity(
            opacity: _i == 0 ? 0.4 : 1,
            child: Container(
              width: 52,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(16),
                border: t.cardBorder,
                boxShadow: t.cardShadow,
              ),
              child: Icon(Icons.arrow_back_rounded, size: 20, color: t.ink2),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 54,
            child: _GradientButton(
              onPressed: () => setState(() => _flipped = true),
              gradient: t.fabGradient,
              shadowColor: t.fabRing,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.flip_rounded, color: Colors.white, size: 19),
                  SizedBox(width: 8),
                  Text(
                    'Lật xem đáp án',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _gradeControls(AppTokens t) {
    return Column(
      children: [
        Text(
          'Bạn có nhớ đáp án không?',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: t.inkMuted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _advance('review'),
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.accentSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 18, color: t.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Cần ôn lại',
                        style: TextStyle(
                          color: t.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: GestureDetector(
                onTap: () => _advance('known'),
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.ok,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: t.ok.withValues(alpha: 0.28),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_rounded, size: 19, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Đã thuộc',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }

  // ───────────────────────── DONE ─────────────────────────
  Widget _doneView(AppTokens t, FlashcardResult r) {
    final pct = r.total == 0 ? 0.0 : r.known / r.total;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
            children: [
              Center(
                child: Image.asset('assets/images/mascot-idle.png', width: 150)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(
                      begin: -7,
                      end: 7,
                      duration: 1300.ms,
                      curve: Curves.easeInOut,
                    ),
              ),
              const SizedBox(height: 14),
              Text(
                'Hoàn thành bộ thẻ!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: t.displayWeight,
                  color: t.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.ink2,
                  ),
                  children: [
                    const TextSpan(text: 'Bạn đã lật hết '),
                    TextSpan(
                      text: '${r.total} thẻ · ${widget.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: t.ink,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Center(
                child: Ring(
                  pct: pct,
                  size: 128,
                  stroke: 12,
                  color: t.ok,
                  track: t.surfaceSunken,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${r.known}',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: t.ink,
                                height: 1,
                              ),
                            ),
                            TextSpan(
                              text: '/${r.total}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: t.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'đã thuộc',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: t.ok,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _breakdownTile(
                      t,
                      icon: Icons.check_rounded,
                      iconColor: t.ok,
                      iconBg: t.ok.withValues(alpha: 0.12),
                      value: r.known,
                      label: 'đã thuộc',
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: _breakdownTile(
                      t,
                      icon: Icons.refresh_rounded,
                      iconColor: t.accent,
                      iconBg: t.accentSoft,
                      value: r.review,
                      label: 'cần ôn lại',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: t.surfaceSunken,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 15, color: t.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Flashcard để ghi nhớ chủ động — không tính điểm hay streak.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: t.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // actions
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            children: [
              if (r.review > 0)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: _GradientButton(
                    onPressed: () {
                      final reviewCards = [
                        for (final e in _marks.entries)
                          if (e.value == 'review') _cards[e.key],
                      ];
                      _restart(reviewCards.isEmpty ? _all : reviewCards);
                    },
                    gradient: t.fabGradient,
                    shadowColor: t.fabRing,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Ôn lại ${r.review} thẻ chưa thuộc',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (r.review > 0) const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ghostBtn(t, 'Học lại từ đầu', () => _restart(_all)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ghostBtn(t, 'Về thư viện', () => context.pop()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _breakdownTile(
    AppTokens t, {
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required int value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.cardRadius),
        border: t.cardBorder,
        boxShadow: t.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: t.ink,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: t.inkMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ghostBtn(AppTokens t, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: t.ink,
          ),
        ),
      ),
    );
  }
}

/// Thẻ lật 3D: rotateY, mặt trước = câu hỏi, mặt sau = đáp án (nền hero).
class _FlipCard extends StatelessWidget {
  final FlashCard card;
  final bool flipped;
  final VoidCallback onFlip;
  final AppTokens t;

  const _FlipCard({
    super.key,
    required this.card,
    required this.flipped,
    required this.onFlip,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFlip,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: flipped ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 550),
        curve: const Cubic(0.4, 0.1, 0.2, 1),
        builder: (ctx, value, _) {
          final angle = value * math.pi;
          final showBack = value > 0.5;
          final content = showBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: _back(),
                )
              : _front();
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: content,
          );
        },
      ),
    );
  }

  Widget _face({required Color? bg, Gradient? gradient, required Widget child}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        color: bg,
        gradient: gradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: t.cardShadow,
        border: bg != null ? t.cardBorder : null,
      ),
      child: child,
    );
  }

  Widget _front() {
    return _face(
      bg: t.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _chip(
                bg: t.primarySoft,
                fg: t.primary,
                icon: Icons.gps_fixed,
                label: 'CÂU HỎI',
              ),
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.surfaceSunken,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(Icons.layers_outlined, size: 16, color: t.inkMuted),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Text(
                card.front,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: t.displayWeight,
                  color: t.ink,
                  height: 1.32,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flip_rounded, size: 17, color: t.inkMuted),
              const SizedBox(width: 7),
              Text(
                'Chạm để lật xem đáp án',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: t.inkMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _back() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          _face(
            bg: null,
            gradient: t.heroGradient,
            child: Column(
              children: [
                Row(
                  children: [
                    _chip(
                      bg: Colors.white.withValues(alpha: 0.18),
                      fg: Colors.white,
                      icon: Icons.check_rounded,
                      label: 'ĐÁP ÁN ĐÚNG',
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      card.back,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flip_rounded,
                      size: 17,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Chạm để xem lại câu hỏi',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required Color bg,
    required Color fg,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút gradient dùng chung.
class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Gradient gradient;
  final Color shadowColor;
  final Widget child;

  const _GradientButton({
    required this.onPressed,
    required this.gradient,
    required this.shadowColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
