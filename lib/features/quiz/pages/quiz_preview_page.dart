import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../data/models/quiz.dart';
import '../../shared/widgets/flow_header.dart';
import '../../shared/widgets/themed_card.dart';
import '../providers/quiz_generation_service.dart';
import '../providers/quizzes_provider.dart';

/// Tham số truyền qua GoRouter `extra` cho trang xem trước bộ câu hỏi.
class QuizPreviewArgs {
  final int documentId;
  final String quizTitle;
  final List<GeneratedQuestionDto> questions;

  const QuizPreviewArgs({
    required this.documentId,
    required this.quizTitle,
    required this.questions,
  });
}

/// Xem trước bộ câu hỏi AI tạo, cho xoá câu chưa ưng, rồi mới **Xuất bản**.
///
/// Theo luồng web (QuizPreviewPage.jsx): quiz CHỈ được tạo trên backend khi
/// bấm Xuất bản — createQuiz → createQuestion từng câu → updateQuiz
/// status `Teacher_Approved` (badge "ĐÃ DUYỆT"). Trước đó chưa có gì lưu.
class QuizPreviewPage extends ConsumerStatefulWidget {
  final QuizPreviewArgs args;
  const QuizPreviewPage({super.key, required this.args});

  @override
  ConsumerState<QuizPreviewPage> createState() => _QuizPreviewPageState();
}

class _QuizPreviewPageState extends ConsumerState<QuizPreviewPage> {
  late final List<GeneratedQuestionDto> _questions = [...widget.args.questions];
  bool _publishing = false;
  bool _published = false;
  int? _publishedQuizId;
  String? _error;

  Future<void> _publish() async {
    if (_publishing || _questions.isEmpty) return;
    setState(() {
      _publishing = true;
      _error = null;
    });
    try {
      final quiz = await QuizGenerationService.instance.saveGeneratedQuiz(
        documentId: widget.args.documentId,
        quizTitle: widget.args.quizTitle,
        questions: _questions,
      );
      _publishedQuizId = quiz.id;
      // Quiz mới đã Teacher_Approved — refresh để thư viện hiện ngay.
      ref.invalidate(documentQuestionsProvider(widget.args.documentId));
      await ref.read(quizzesProvider.notifier).refresh();
      if (!mounted) return;
      setState(() => _published = true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _publishing = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _confirmBack() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bỏ bộ câu hỏi này?'),
        content: const Text(
          'Bộ câu hỏi chưa được xuất bản và sẽ mất nếu bạn quay lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ở lại'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bỏ'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) context.go('/student');
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: t.appBg,
      body: SafeArea(
        child: _published
            ? _publishedView(t)
            : Column(
                children: [
                  FlowHeader(
                    title: 'Xem trước bộ câu hỏi',
                    subtitle: widget.args.quizTitle,
                    onBack: _confirmBack,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
                      children: [
                        _statsRow(t),
                        const SizedBox(height: 14),
                        ...List.generate(
                          _questions.length,
                          (i) => _questionCard(t, i),
                        ),
                      ],
                    ),
                  ),
                  _publishBar(t),
                ],
              ),
      ),
    );
  }

  Widget _statsRow(AppTokens t) {
    final n = _questions.length;
    final minutes = (n * 30 / 60).ceil();
    return Text(
      '$n câu hỏi  ·  $n điểm  ·  ~$minutes phút',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: t.ink),
    );
  }

  Widget _questionCard(AppTokens t, int index) {
    final q = _questions[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ThemedCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'${index + 1}'.padLeft(2, '0')}  TRẮC NGHIỆM · 30 giây · 1 điểm',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: t.inkMuted,
                    ),
                  ),
                ),
                if (_questions.length > 1)
                  GestureDetector(
                    onTap: () => setState(() => _questions.removeAt(index)),
                    child: Icon(
                      Icons.delete_outline,
                      size: 19,
                      color: t.inkMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              q.questionText,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: t.ink,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            ...q.options.map(
              (o) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      o.isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: o.isCorrect ? t.ok : t.inkMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        o.optionText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: o.isCorrect
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: o.isCorrect ? t.ink : t.ink2,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _publishBar(AppTokens t) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
      decoration: BoxDecoration(color: t.surface, boxShadow: t.cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
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
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _publishing ? null : _publish,
              icon: _publishing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
              label: Text(_publishing ? 'Đang xuất bản…' : 'Xuất bản'),
              style:
                  ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    shadowColor: t.fabRing,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ).copyWith(
                    backgroundBuilder: (ctx, st, child) => Ink(
                      decoration: BoxDecoration(
                        gradient: t.fabGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: child,
                    ),
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI có thể mắc lỗi. Hãy xem lại trước khi dùng trong lớp.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: t.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _publishedView(AppTokens t) {
    return Padding(
          padding: const EdgeInsets.fromLTRB(22, 40, 22, 24),
          child: Column(
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.ok.withValues(alpha: 0.12),
                      ),
                    ),
                    Image.asset('assets/images/mascot-idle.png', width: 128),
                    Positioned(
                      top: 6,
                      right: 14,
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
                'Đã xuất bản!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: t.displayWeight,
                  color: t.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 280,
                child: Text(
                  'Quiz của bạn đã sẵn sàng, bạn có thể xem ở Thư viện.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: t.ink2,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  // Chơi ĐÚNG quiz vừa xuất bản (giống web targetQuizId) —
                  // không đi qua documentId để khỏi dính quiz cũ của doc.
                  onPressed: () => context.go(
                    _publishedQuizId != null
                        ? '/student/quiz?quizId=$_publishedQuizId'
                        : '/student/doc-detail?id=${widget.args.documentId}',
                  ),
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  label: const Text('Làm thử bộ câu hỏi'),
                  style:
                      ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        shadowColor: t.fabRing,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ).copyWith(
                        backgroundBuilder: (ctx, st, child) => Ink(
                          decoration: BoxDecoration(
                            gradient: t.fabGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: child,
                        ),
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
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
