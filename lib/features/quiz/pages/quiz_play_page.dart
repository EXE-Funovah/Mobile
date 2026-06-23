import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../data/models/quiz_attempt.dart';
import '../../shared/widgets/pill.dart';
import '../data/quiz_data.dart';
import '../providers/quizzes_provider.dart';
import '../providers/user_stats_provider.dart';

class QuizPlayPage extends ConsumerStatefulWidget {
  final int? quizId;
  final int? documentId;
  const QuizPlayPage({super.key, this.quizId, this.documentId});

  @override
  ConsumerState<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends ConsumerState<QuizPlayPage> {
  int _i = 0;
  int? _picked;
  int _score = 0;
  final _watch = Stopwatch()..start();
  bool _submitting = false;
  // Lưu lựa chọn từng câu để gửi backend chấm (server-side scoring)
  final List<QuizAnswerSubmit> _answers = [];
  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  void dispose() {
    _watch.stop();
    super.dispose();
  }

  void _pick(int idx, List<QuizQ> qs) {
    if (_picked != null) return;
    final q = qs[_i.clamp(0, qs.length - 1)];
    setState(() {
      _picked = idx;
      if (idx == q.correct) _score++;
    });
    // Ghi lại answer nếu có id thật từ API
    if (q.questionId > 0 && idx < q.optionIds.length) {
      _answers.add(
        QuizAnswerSubmit(
          questionId: q.questionId,
          optionId: q.optionIds[idx],
        ),
      );
    }
  }

  Future<void> _next(List<QuizQ> qs) async {
    if (_i >= qs.length - 1) {
      if (_submitting) return;
      _submitting = true;
      _watch.stop();

      // Submit answers để backend tự chấm + cộng XP/streak.
      // Cần đủ answers cho mọi câu (BE validate count khớp).
      if (widget.quizId != null && _answers.length == qs.length) {
        try {
          await ref.read(submitQuizAttemptProvider)(
            QuizAttemptSubmitRequest(
              quizId: widget.quizId!,
              durationSeconds: _watch.elapsed.inSeconds,
              answers: List.of(_answers),
            ),
          );
        } catch (_) {
          // Không chặn kết quả nếu submit lỗi (offline…) — XP mất lần này.
        }
      }

      if (!mounted) return;
      context.go('/student/quiz/result?score=$_score&total=${qs.length}');
    } else {
      setState(() {
        _i++;
        _picked = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);

    final AsyncValue<List<QuizQ>> asyncQs;
    if (widget.quizId != null) {
      asyncQs = ref.watch(quizQuestionsProvider(widget.quizId!));
    } else if (widget.documentId != null) {
      asyncQs = ref.watch(documentQuestionsProvider(widget.documentId!));
    } else {
      asyncQs = const AsyncValue.data(<QuizQ>[]);
    }

    return asyncQs.when(
      loading: () => Scaffold(
        backgroundColor: t.appBg,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: t.appBg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: t.danger),
                const SizedBox(height: 10),
                Text(
                  err.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: t.ink2),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    if (widget.quizId != null) {
                      ref.invalidate(quizQuestionsProvider(widget.quizId!));
                    } else if (widget.documentId != null) {
                      ref.invalidate(
                        documentQuestionsProvider(widget.documentId!),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (qs) {
        if (qs.isEmpty) {
          return Scaffold(
            backgroundColor: t.appBg,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Không tìm thấy câu hỏi nào.',
                    style: TextStyle(color: t.ink),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/student');
                      }
                    },
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final total = qs.length;
        final currentIndex = _i.clamp(0, total - 1);
        final q = qs[currentIndex];
        final answered = _picked != null;
        final isLast = currentIndex == total - 1;
        final progress = (currentIndex + (answered ? 1 : 0)) / total;

        return Scaffold(
          backgroundColor: t.appBg,
          body: SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: Row(
                    children: [
                      Material(
                        color: t.surfaceSunken,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/student');
                            }
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            child: Icon(Icons.close, color: t.ink2, size: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            height: 10,
                            child: Stack(
                              children: [
                                Container(color: t.surfaceSunken),
                                AnimatedFractionallySizedBox(
                                  duration: const Duration(milliseconds: 350),
                                  widthFactor: progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: t.fabGradient,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: t.accentSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, size: 15, color: t.accent),
                            const SizedBox(width: 3),
                            Text(
                              '${_score * 10}',
                              style: TextStyle(
                                color: t.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Câu ${currentIndex + 1} / $total',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: t.inkMuted,
                              ),
                            ),
                            Pill(
                              tint: q.lv == 1 ? 2 : (q.lv == 2 ? 0 : 1),
                              child: Text('Cấp ${q.lv}'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                              key: ValueKey(currentIndex),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    q.q,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: t.displayWeight,
                                      color: t.ink,
                                      height: 1.3,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  ...List.generate(q.opts.length, (idx) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 11,
                                      ),
                                      child: _optionTile(
                                        t,
                                        q,
                                        idx,
                                        answered,
                                        qs,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            )
                            .animate(key: ValueKey(currentIndex))
                            .fadeIn(duration: 300.ms)
                            .scale(
                              duration: 300.ms,
                              begin: const Offset(0.97, 0.97),
                              end: const Offset(1, 1),
                            ),
                      ],
                    ),
                  ),
                ),

                // Feedback panel
                if (answered)
                  Container(
                        padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
                        decoration: BoxDecoration(
                          color: t.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x140F1E33),
                              blurRadius: 24,
                              offset: Offset(0, -8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _picked == q.correct
                                        ? t.ok
                                        : t.danger,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _picked == q.correct
                                        ? Icons.check
                                        : Icons.close,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _picked == q.correct
                                            ? 'Chính xác! +10 XP'
                                            : 'Chưa đúng',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: _picked == q.correct
                                              ? t.ok
                                              : t.danger,
                                        ),
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Đáp án: ',
                                              style: TextStyle(
                                                color: t.inkMuted,
                                              ),
                                            ),
                                            TextSpan(
                                              text: q.opts[q.correct],
                                              style: TextStyle(
                                                color: t.ink,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => _next(qs),
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: t.fabGradient,
                                  borderRadius: BorderRadius.circular(15),
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
                                      isLast ? 'Xem kết quả' : 'Câu tiếp theo',
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
                          ],
                        ),
                      )
                      .animate()
                      .scale(
                        duration: 300.ms,
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                      )
                      .fadeIn(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _optionTile(
    AppTokens t,
    QuizQ q,
    int idx,
    bool answered,
    List<QuizQ> qs,
  ) {
    final isCorrect = idx == q.correct;
    final isPicked = idx == _picked;

    Color bg = t.surface;
    Color ink = t.ink;
    Color badgeBg = t.tints[idx];
    Color badgeInk = t.tintInks[idx];
    List<BoxShadow>? shadow = t.cardShadow;
    Border? border = t.cardBorder;
    Widget? trailing;
    double scale = 1;

    if (answered && isCorrect) {
      bg = t.ok;
      ink = Colors.white;
      badgeBg = Colors.white.withValues(alpha: 0.25);
      badgeInk = Colors.white;
      shadow = [
        BoxShadow(
          color: t.ok.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
      border = null;
      trailing = const Icon(Icons.check_rounded, color: Colors.white, size: 22);
    } else if (answered && isPicked && !isCorrect) {
      bg = t.danger;
      ink = Colors.white;
      badgeBg = Colors.white.withValues(alpha: 0.25);
      badgeInk = Colors.white;
      shadow = [
        BoxShadow(
          color: t.danger.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
      border = null;
      trailing = const Icon(Icons.close_rounded, color: Colors.white, size: 22);
      scale = 0.98;
    } else if (answered) {
      ink = t.inkMuted;
      shadow = null;
    }

    return GestureDetector(
      onTap: answered ? null : () => _pick(idx, qs),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.diagonal3Values(scale, scale, 1.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(17),
          boxShadow: shadow,
          border: border,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: Text(
                _letters[idx],
                style: TextStyle(
                  color: badgeInk,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                q.opts[idx],
                style: TextStyle(
                  color: ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
            // ignore: use_null_aware_elements
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
