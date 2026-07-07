import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../data/api/ai_api.dart';
import '../../shared/widgets/flow_header.dart';
import '../../shared/widgets/themed_card.dart';
import 'quiz_preview_page.dart';

/// Tham số: tạo bộ câu hỏi mới từ 1 tài liệu ĐÃ upload (không upload lại).
class GenerateQuizArgs {
  final int documentId;
  final String docName;
  final String fileUrl; // presignedUrl của tài liệu

  const GenerateQuizArgs({
    required this.documentId,
    required this.docName,
    required this.fileUrl,
  });
}

const _difficultyOptions = [
  (label: 'Nhận biết', value: 'Dễ'),
  (label: 'Thông hiểu', value: 'Vừa'),
  (label: 'Nâng cao', value: 'Khó'),
];

const _countOptions = [
  (label: 'Tự động', value: 5),
  (label: '10', value: 10),
  (label: '15', value: 15),
  (label: '20', value: 20),
  (label: '30', value: 30),
];

/// Tạo bộ câu hỏi từ tài liệu đã có: chọn cấu hình → AI sinh → sang xem trước
/// (`QuizPreviewPage`) → xuất bản. Giải quyết trường hợp upload tài liệu nhưng
/// chưa tạo câu hỏi — sau này mở lại tài liệu vẫn tạo được bộ câu hỏi.
class GenerateQuizFromDocPage extends ConsumerStatefulWidget {
  final GenerateQuizArgs args;
  const GenerateQuizFromDocPage({super.key, required this.args});

  @override
  ConsumerState<GenerateQuizFromDocPage> createState() =>
      _GenerateQuizFromDocPageState();
}

class _GenerateQuizFromDocPageState
    extends ConsumerState<GenerateQuizFromDocPage> {
  late final TextEditingController _titleCtl = TextEditingController(
    text: 'Trắc nghiệm: ${widget.args.docName}',
  );
  String _difficulty = 'Vừa';
  int _numQuestions = 5;
  bool _generating = false;
  String? _error;

  @override
  void dispose() {
    _titleCtl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final title = _titleCtl.text.trim().isEmpty
        ? 'Trắc nghiệm: ${widget.args.docName}'
        : _titleCtl.text.trim();
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      final questions = await AiApi.instance.generateQuestions(
        fileUrl: widget.args.fileUrl,
        documentId: widget.args.documentId,
        quizTitle: title,
        numberOfQuestions: _numQuestions,
        difficulty: _difficulty,
      );
      if (!mounted) return;
      context.pushReplacement(
        '/student/quiz-preview',
        extra: QuizPreviewArgs(
          documentId: widget.args.documentId,
          quizTitle: title,
          questions: questions,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generating = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: t.appBg,
      body: SafeArea(
        child: Column(
          children: [
            FlowHeader(
              title: 'Tạo bộ câu hỏi',
              subtitle: widget.args.docName,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: _generating
                  ? _processingView(t)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
                      child: _configView(t),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _configView(AppTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ThemedCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: t.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.description, color: t.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.args.docName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: t.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _label(t, 'Tên bộ câu hỏi'),
        const SizedBox(height: 8),
        TextField(
          controller: _titleCtl,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: t.ink,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: t.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: t.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: t.line),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _label(t, 'Độ sâu kiến thức (DOK)'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _difficultyOptions.map((o) {
            return _choiceChip(
              t,
              o.label,
              _difficulty == o.value,
              () => setState(() => _difficulty = o.value),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        _label(t, 'Số lượng câu hỏi'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _countOptions.map((o) {
            return _choiceChip(
              t,
              o.label,
              _numQuestions == o.value,
              () => setState(() => _numQuestions = o.value),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
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
          child: ElevatedButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.auto_awesome, color: Colors.white),
            label: const Text('Tạo bộ câu hỏi'),
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
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                  ),
                ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'AI có thể mắc lỗi. Bạn sẽ xem lại bộ câu hỏi trước khi xuất bản.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: t.inkMuted,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _processingView(AppTokens t) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
                  gradient: RadialGradient(
                    colors: [t.primarySoft, Colors.transparent],
                    stops: const [0, 0.7],
                  ),
                ),
              ),
              Image.asset('assets/images/main-mascot-full.png', width: 132)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(duration: 2400.ms, begin: 0, end: -8),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sumadi đang soạn câu hỏi…',
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

  Widget _label(AppTokens t, String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: t.ink),
    );
  }

  Widget _choiceChip(
    AppTokens t,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? t.primary : t.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? t.primary : t.line),
          boxShadow: selected ? t.cardShadow : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : t.ink2,
          ),
        ),
      ),
    );
  }
}
