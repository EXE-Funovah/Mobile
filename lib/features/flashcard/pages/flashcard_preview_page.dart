import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../data/api/quiz_api.dart';
import '../../shared/widgets/flow_header.dart';
import '../../shared/widgets/themed_card.dart';
import '../../student/providers/nav_providers.dart';
import '../../shared/widgets/student_bottom_nav.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_providers.dart';

/// Tham số cho trang xem trước flashcard (truyền qua GoRouter `extra`).
class FlashcardPreviewArgs {
  final int documentId;
  final String title;

  const FlashcardPreviewArgs({required this.documentId, required this.title});
}

/// Xem trước bộ thẻ AI đã soạn (từ bộ câu hỏi của tài liệu), xoá thẻ chưa ưng
/// rồi **Xuất bản** với `activityType = Flashcard` qua `POST /api/Quiz/publish`.
class FlashcardPreviewPage extends ConsumerStatefulWidget {
  final FlashcardPreviewArgs args;
  const FlashcardPreviewPage({super.key, required this.args});

  @override
  ConsumerState<FlashcardPreviewPage> createState() =>
      _FlashcardPreviewPageState();
}

enum _Phase { loading, review, publishing, done }

class _FlashcardPreviewPageState extends ConsumerState<FlashcardPreviewPage> {
  final List<FlashCard> _cards = [];
  _Phase _phase = _Phase.loading;
  String? _error;
  int _publishedCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _phase = _Phase.loading;
      _error = null;
    });
    try {
      final cards = await ref.read(
        flashcardCardsFromDocProvider(widget.args.documentId).future,
      );
      if (!mounted) return;
      setState(() {
        _cards
          ..clear()
          ..addAll(cards);
        _phase = _Phase.review;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.review;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _publish() async {
    if (_cards.isEmpty) return;
    setState(() {
      _phase = _Phase.publishing;
      _error = null;
    });
    try {
      final questions = <Map<String, dynamic>>[];
      for (var i = 0; i < _cards.length; i++) {
        final c = _cards[i];
        questions.add({
          'questionText': c.front,
          'questionType': 'Flashcard',
          'position': i,
          'options': [
            {'optionText': c.back, 'isCorrect': true},
          ],
        });
      }
      await QuizApi.instance.publish(
        documentId: widget.args.documentId,
        title: widget.args.title,
        activityType: 'Flashcard',
        questions: questions,
      );
      ref.invalidate(flashcardSetsProvider);
      if (!mounted) return;
      setState(() {
        _publishedCount = _cards.length;
        _phase = _Phase.done;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.review;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _goLibraryFlashTab() {
    ref.read(libraryTabProvider.notifier).state = 'flash';
    ref.read(studentTabRequestProvider.notifier).state = NavTab.library;
    context.go('/student');
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: t.appBg,
      body: SafeArea(
        child: (_phase == _Phase.publishing || _phase == _Phase.done)
            ? _statusView(t)
            : Column(
                children: [
                  FlowHeader(
                    title: 'Xem trước flashcard',
                    subtitle: widget.args.title,
                    onBack: () => context.pop(),
                  ),
                  Expanded(child: _reviewBody(t)),
                  _publishBar(t),
                ],
              ),
      ),
    );
  }

  Widget _reviewBody(AppTokens t) {
    if (_phase == _Phase.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_cards.isEmpty && _error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 44, color: t.inkMuted),
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.ink2, fontSize: 13.5, height: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy tạo bộ câu hỏi cho tài liệu này trước, rồi quay lại tạo flashcard.',
              textAlign: TextAlign.center,
              style: TextStyle(color: t.inkMuted, fontSize: 12.5, height: 1.5),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
      children: [
        // mascot note
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: t.primarySoft,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Image.asset('assets/images/mascot-head.png', width: 50),
              const SizedBox(width: 13),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: t.ink2,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Tanuki đã soạn '),
                      TextSpan(
                        text: 'bộ thẻ ghi nhớ',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' từ tài liệu. Xem lại, xoá thẻ chưa ưng rồi xuất bản nhé.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        // count + legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_cards.length} thẻ ghi nhớ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: t.ink,
              ),
            ),
            Row(
              children: [
                _legendDot(t, t.primary, 'Mặt trước'),
                const SizedBox(width: 12),
                _legendDot(t, t.ok, 'Mặt sau'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_cards.length, (i) => _cardTile(t, i)),
        if (_cards.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Đã xoá hết thẻ. Quay lại để tạo bộ mới.',
                style: TextStyle(
                  color: t.inkMuted,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _legendDot(AppTokens t, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: t.inkMuted,
          ),
        ),
      ],
    );
  }

  Widget _cardTile(AppTokens t, int i) {
    final c = _cards[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: ThemedCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // front row
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: t.primarySoft,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: t.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CÂU HỎI',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: t.primary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          c.front,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: t.ink,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => _cards.removeAt(i)),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: t.surfaceSunken,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 17,
                        color: t.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // back row
            Container(
              margin: const EdgeInsets.only(left: 53, right: 15),
              padding: const EdgeInsets.fromLTRB(0, 11, 0, 13),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: t.line, style: BorderStyle.solid),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ĐÁP ÁN',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: t.ok,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    c.back,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: t.ink2,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().scale(
        duration: 300.ms,
        curve: Curves.easeOut,
        begin: const Offset(0.86, 0.86),
        end: const Offset(1, 1),
      ),
    );
  }

  Widget _publishBar(AppTokens t) {
    final enabled = _cards.isNotEmpty && _phase == _Phase.review;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
      decoration: BoxDecoration(
        color: t.appBg,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null && _cards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: t.danger,
                ),
              ),
            ),
          SizedBox(
            height: 54,
            child: _GradientButton(
              onPressed: enabled ? _publish : null,
              gradient: t.fabGradient,
              shadowColor: t.fabRing,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.layers_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Xuất bản ${_cards.length} thẻ',
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
        ],
      ),
    );
  }

  Widget _statusView(AppTokens t) {
    if (_phase == _Phase.publishing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/mascot-speaking.png', width: 130)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: -7, end: 7, duration: 1200.ms, curve: Curves.easeInOut),
          const SizedBox(height: 12),
          Text(
            'Đang xuất bản bộ thẻ…',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: t.ink,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 3, color: t.primary),
          ),
        ],
      );
    }
    // done
    return Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.ok.withValues(alpha: 0.12),
                      ),
                    ),
                    Image.asset('assets/images/mascot-idle.png', width: 128),
                    Positioned(
                      top: 8,
                      right: 16,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: t.ok,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.appBg, width: 3),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Đã xuất bản $_publishedCount thẻ!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: t.displayWeight,
                  color: t.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 270,
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: t.ink2,
                      height: 1.55,
                    ),
                    children: [
                      const TextSpan(text: 'Bộ flashcard đã vào '),
                      TextSpan(
                        text: 'Thư viện · tab Flashcard',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                        ),
                      ),
                      const TextSpan(
                        text: '. Học lật thẻ bất cứ lúc nào.',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: _GradientButton(
                  onPressed: _goLibraryFlashTab,
                  gradient: t.fabGradient,
                  shadowColor: t.fabRing,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Xem trong thư viện',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .scale(
          duration: 400.ms,
          curve: Curves.easeOutBack,
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
        )
        .fadeIn();
  }
}

/// Nút gradient dùng chung (khớp `_GradientButton` trong doc_detail_page).
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
    final disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
