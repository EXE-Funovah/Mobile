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

/// Câu hỏi có thể chỉnh sửa trong màn xem trước (id ổn định cho widget key).
class _EditableQuestion {
  final int id;
  String text;
  List<_EditableOption> options;
  _EditableQuestion({required this.id, required this.text, required this.options});
}

class _EditableOption {
  final int id;
  String text;
  bool correct;
  _EditableOption({required this.id, required this.text, required this.correct});
}

/// Xem trước bộ câu hỏi AI tạo — **sửa được** (giống web): chỉnh nội dung câu
/// hỏi, sửa đáp án, chọn đáp án đúng, thêm/xoá câu, rồi mới **Xuất bản**.
class QuizPreviewPage extends ConsumerStatefulWidget {
  final QuizPreviewArgs args;
  const QuizPreviewPage({super.key, required this.args});

  @override
  ConsumerState<QuizPreviewPage> createState() => _QuizPreviewPageState();
}

class _QuizPreviewPageState extends ConsumerState<QuizPreviewPage> {
  late final List<_EditableQuestion> _questions;
  int _nextId = 0;
  bool _publishing = false;
  bool _published = false;
  int? _publishedQuizId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _questions = widget.args.questions.map((q) {
      return _EditableQuestion(
        id: _nextId++,
        text: q.questionText,
        options: q.options
            .map(
              (o) => _EditableOption(
                id: _nextId++,
                text: o.optionText,
                correct: o.isCorrect,
              ),
            )
            .toList(),
      );
    }).toList();
    // Đảm bảo mỗi câu có đúng 1 đáp án đúng (AI đôi khi trả thiếu).
    for (final q in _questions) {
      if (!q.options.any((o) => o.correct) && q.options.isNotEmpty) {
        q.options.first.correct = true;
      }
    }
  }

  /// Kiểm tra hợp lệ trước khi xuất bản (khớp validate backend cho MCQ).
  String? _validate() {
    if (_questions.isEmpty) return 'Cần ít nhất 1 câu hỏi.';
    for (var i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final n = i + 1;
      if (q.text.trim().isEmpty) return 'Câu $n chưa có nội dung.';
      final opts = q.options.where((o) => o.text.trim().isNotEmpty).toList();
      if (opts.length < 2) return 'Câu $n cần ít nhất 2 đáp án.';
      if (q.options.where((o) => o.correct).length != 1) {
        return 'Câu $n cần đúng 1 đáp án đúng.';
      }
      final correct = q.options.firstWhere((o) => o.correct);
      if (correct.text.trim().isEmpty) {
        return 'Câu $n: đáp án đúng không được để trống.';
      }
    }
    return null;
  }

  Future<void> _publish() async {
    if (_publishing) return;
    final err = _validate();
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _publishing = true;
      _error = null;
    });
    try {
      final payload = _questions.map((q) {
        return GeneratedQuestionDto(
          questionText: q.text.trim(),
          questionType: 'MultipleChoice',
          options: q.options
              .where((o) => o.text.trim().isNotEmpty)
              .map(
                (o) => GeneratedOptionDto(
                  optionText: o.text.trim(),
                  isCorrect: o.correct,
                ),
              )
              .toList(),
        );
      }).toList();

      final quiz = await QuizGenerationService.instance.saveGeneratedQuiz(
        documentId: widget.args.documentId,
        quizTitle: widget.args.quizTitle,
        questions: payload,
      );
      _publishedQuizId = quiz.id;
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

  void _addQuestion() {
    setState(() {
      _questions.add(
        _EditableQuestion(
          id: _nextId++,
          text: '',
          options: [
            _EditableOption(id: _nextId++, text: '', correct: true),
            _EditableOption(id: _nextId++, text: '', correct: false),
          ],
        ),
      );
      _error = null;
    });
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
                        const SizedBox(height: 4),
                        _addQuestionBtn(t),
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
    return Text(
      '$n câu hỏi  ·  chạm để sửa nội dung',
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
                    'CÂU ${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: t.primary,
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
            // Nội dung câu hỏi — sửa được
            TextFormField(
              key: ValueKey('q${q.id}'),
              initialValue: q.text,
              onChanged: (v) => q.text = v,
              minLines: 1,
              maxLines: 4,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: t.ink,
                height: 1.4,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Nhập nội dung câu hỏi…',
                filled: true,
                fillColor: t.surface2,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: t.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: t.line),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              q.options.length,
              (oi) => _optionRow(t, q, oi),
            ),
            const SizedBox(height: 4),
            if (q.options.length < 6)
              TextButton.icon(
                onPressed: () => setState(() {
                  q.options.add(
                    _EditableOption(id: _nextId++, text: '', correct: false),
                  );
                }),
                icon: Icon(Icons.add, size: 18, color: t.primary),
                label: Text(
                  'Thêm đáp án',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: t.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _optionRow(AppTokens t, _EditableQuestion q, int oi) {
    final o = q.options[oi];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Chọn đáp án đúng (radio — chỉ 1 đúng)
          GestureDetector(
            onTap: () => setState(() {
              for (final x in q.options) {
                x.correct = false;
              }
              o.correct = true;
            }),
            child: Icon(
              o.correct
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              size: 22,
              color: o.correct ? t.ok : t.inkMuted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              key: ValueKey('o${o.id}'),
              initialValue: o.text,
              onChanged: (v) => o.text = v,
              minLines: 1,
              maxLines: 3,
              style: TextStyle(
                fontSize: 13,
                fontWeight: o.correct ? FontWeight.w700 : FontWeight.w600,
                color: o.correct ? t.ink : t.ink2,
                height: 1.4,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Đáp án…',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: t.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: t.line),
                ),
              ),
            ),
          ),
          if (q.options.length > 2)
            GestureDetector(
              onTap: () => setState(() {
                final wasCorrect = o.correct;
                q.options.removeAt(oi);
                if (wasCorrect && !q.options.any((x) => x.correct)) {
                  q.options.first.correct = true;
                }
              }),
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(Icons.close, size: 18, color: t.inkMuted),
              ),
            ),
        ],
      ),
    );
  }

  Widget _addQuestionBtn(AppTokens t) {
    return GestureDetector(
      onTap: _addQuestion,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: t.primarySoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 20, color: t.primary),
            const SizedBox(width: 8),
            Text(
              'Thêm câu hỏi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: t.primary,
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
                    Image.asset(
                      'assets/images/main-mascot-full.png',
                      width: 128,
                    ),
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
