import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/decorative_blob.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/mascot_avatar.dart';

/// Luồng: chọn tài liệu → upload → AI gen quiz → review → save
enum _Step {
  pickFile,    // 1. Chọn file
  uploading,   // 2. Upload lên S3 (qua presigned URL)
  generating,  // 3. AI đang tạo câu hỏi
  preview,     // 4. Xem trước quiz, cho chỉnh sửa
  saved,       // 5. Đã lưu thành công
}

class CreateQuizFromDocPage extends StatefulWidget {
  const CreateQuizFromDocPage({super.key});

  @override
  State<CreateQuizFromDocPage> createState() => _CreateQuizFromDocPageState();
}

class _CreateQuizFromDocPageState extends State<CreateQuizFromDocPage> {
  _Step _step = _Step.pickFile;
  PlatformFile? _file;
  String _quizTitle = '';
  int _numQuestions = 5;
  String _difficulty = 'Vừa';
  double _progress = 0;

  // Stub generated questions cho UI demo
  List<_GeneratedQuestion> _questions = [];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt', 'png', 'jpg', 'jpeg'],
    );
    if (result == null) return;
    final f = result.files.first;
    setState(() {
      _file = f;
      _quizTitle = _stripExt(f.name);
    });
  }

  String _stripExt(String name) {
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  IconData _iconFor(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'docx':
      case 'doc':
        return Icons.article;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _colorFor(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFDC2626);
      case 'docx':
      case 'doc':
        return const Color(0xFF2563EB);
      case 'png':
      case 'jpg':
      case 'jpeg':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.inkSecondary;
    }
  }

  Future<void> _startGenerate() async {
    if (_file == null) return;
    setState(() {
      _step = _Step.uploading;
      _progress = 0;
    });

    // TODO: thật sự gọi
    //  1) POST /api/Document/generate-upload-url {fileName, contentType}
    //  2) PUT s3 presignedUrl với bytes
    //  3) POST /api/Document {s3Key}
    //  4) POST /api/Quiz {documentId, title}
    //  5) BE/AI service tự gen câu hỏi → POST /api/Question + /api/Option
    // Giả lập progress upload 0..1 trong 2s
    for (var i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() => _progress = i / 10);
    }

    setState(() => _step = _Step.generating);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _questions = _stubQuestions(_numQuestions);
      _step = _Step.preview;
    });
  }

  List<_GeneratedQuestion> _stubQuestions(int n) {
    final samples = [
      _GeneratedQuestion(
        text: '${_quizTitle.isEmpty ? "Bài học" : _quizTitle}: Câu nào đúng?',
        options: [
          _Opt('Phương án A', true),
          _Opt('Phương án B', false),
          _Opt('Phương án C', false),
          _Opt('Phương án D', false),
        ],
      ),
      _GeneratedQuestion(
        text: 'Theo tài liệu, kết luận chính là gì?',
        options: [
          _Opt('Kết luận thứ nhất', false),
          _Opt('Kết luận thứ hai', true),
          _Opt('Cả hai đều đúng', false),
          _Opt('Không có kết luận', false),
        ],
      ),
      _GeneratedQuestion(
        text: 'Khái niệm nào sau đây được nhắc đến?',
        options: [
          _Opt('Khái niệm 1', false),
          _Opt('Khái niệm 2', false),
          _Opt('Khái niệm 3', true),
          _Opt('Tất cả phương án trên', false),
        ],
      ),
    ];
    return List.generate(n, (i) => samples[i % samples.length]);
  }

  void _saveQuiz() async {
    setState(() => _step = _Step.saved);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tạo quiz từ tài liệu'),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.pickFile:
        return _pickFileStep(key: const ValueKey('pick'));
      case _Step.uploading:
        return _uploadingStep(key: const ValueKey('upload'));
      case _Step.generating:
        return _generatingStep(key: const ValueKey('gen'));
      case _Step.preview:
        return _previewStep(key: const ValueKey('preview'));
      case _Step.saved:
        return _savedStep(key: const ValueKey('saved'));
    }
  }

  // ======== STEP 1: Pick file ========
  Widget _pickFileStep({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepIndicator(current: 1, total: 4),
          const SizedBox(height: 20),
          const Text(
            'Tải tài liệu lên',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mascot AI sẽ đọc tài liệu và tạo câu hỏi giúp bạn',
            style: TextStyle(color: AppColors.inkSecondary),
          ),
          const SizedBox(height: 24),

          // Upload area
          GestureDetector(
            onTap: _pickFile,
            child: DottedBorderBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: AppColors.brandBlue,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Chạm để chọn tài liệu',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'PDF, Word, ảnh, văn bản',
                      style: TextStyle(
                          color: AppColors.inkMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_file != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _colorFor(_file!.extension)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_iconFor(_file!.extension),
                        color: _colorFor(_file!.extension)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_file!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        Text(_formatSize(_file!.size),
                            style: const TextStyle(
                                color: AppColors.inkMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.inkMuted, size: 20),
                    onPressed: () => setState(() => _file = null),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 24),

            // Title input
            const Text('Tên quiz',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: _quizTitle,
              onChanged: (v) => _quizTitle = v,
              decoration: const InputDecoration(
                hintText: 'Đặt tên cho quiz',
              ),
            ),
            const SizedBox(height: 16),

            // Number of questions
            const Text('Số câu hỏi',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [3, 5, 10, 15, 20].map((n) {
                final selected = _numQuestions == n;
                return ChoiceChip(
                  label: Text('$n câu'),
                  selected: selected,
                  onSelected: (_) => setState(() => _numQuestions = n),
                  selectedColor: AppColors.brandBlue,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                      color:
                          selected ? AppColors.brandBlue : AppColors.border),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Difficulty
            const Text('Độ khó',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: ['Dễ', 'Vừa', 'Khó'].map((d) {
                final selected = _difficulty == d;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: d == 'Khó' ? 0 : 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _difficulty = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.brandBlue.withValues(alpha: 0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.brandBlue
                                : AppColors.border,
                            width: selected ? 2 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? AppColors.brandBlue
                                  : AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            GradientButton(
              label: 'Tạo quiz với Mascot AI',
              icon: Icons.auto_awesome,
              onPressed: _quizTitle.trim().isEmpty ? null : _startGenerate,
            ),
          ],
        ],
      ),
    );
  }

  // ======== STEP 2: Uploading ========
  Widget _uploadingStep({Key? key}) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_upload,
                  size: 56, color: AppColors.brandBlue),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                    duration: 1.seconds,
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.05, 1.05)),
            const SizedBox(height: 24),
            const Text('Đang tải tài liệu...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(_file?.name ?? '',
                style: const TextStyle(color: AppColors.inkMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: 280,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 8,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.brandBlue),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(_progress * 100).toInt()}%',
              style: const TextStyle(
                  color: AppColors.brandBlue, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  // ======== STEP 3: AI generating ========
  Widget _generatingStep({Key? key}) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(3, (i) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accentPink.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .scale(
                          delay: (i * 600).ms,
                          duration: 1800.ms,
                          begin: const Offset(0.4, 0.4),
                          end: const Offset(1, 1),
                          curve: Curves.easeOut,
                        )
                        .fadeOut(delay: (i * 600 + 600).ms, duration: 1200.ms);
                  }),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        AppColors.accentPink,
                        AppColors.accentOrange,
                      ]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentPink.withValues(alpha: 0.5),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: const MascotAvatar(size: 100, bgColor: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mascot đang tạo câu hỏi...',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Đang phân tích tài liệu và soạn $_numQuestions câu hỏi',
              style: const TextStyle(color: AppColors.inkSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const _GeneratingHints(),
          ],
        ),
      ),
    );
  }

  // ======== STEP 4: Preview ========
  Widget _previewStep({Key? key}) {
    return Column(
      key: key,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentEmerald.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            size: 14, color: AppColors.accentEmerald),
                        SizedBox(width: 4),
                        Text(
                          'Đã tạo xong',
                          style: TextStyle(
                            color: AppColors.accentEmerald,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _quizTitle,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '${_questions.length} câu • $_difficulty',
                style: const TextStyle(color: AppColors.inkSecondary),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _questions.length,
            itemBuilder: (_, i) {
              final q = _questions[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            gradient: AppColors.gradientBrand,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            q.text,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...q.options.map((o) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: o.isCorrect
                                ? AppColors.accentEmerald.withValues(alpha: 0.1)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: o.isCorrect
                                  ? AppColors.accentEmerald
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                o.isCorrect
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 18,
                                color: o.isCorrect
                                    ? AppColors.accentEmerald
                                    : AppColors.inkMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  o.text,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: o.isCorrect
                                        ? AppColors.ink
                                        : AppColors.inkSecondary,
                                    fontWeight: o.isCorrect
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: (i * 80).ms, duration: 300.ms)
                  .moveY(begin: 12, end: 0);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _startGenerate,
                  child: const Text('Tạo lại'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GradientButton(
                  label: 'Lưu quiz',
                  icon: Icons.check,
                  onPressed: _saveQuiz,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  // ======== STEP 5: Saved ========
  Widget _savedStep({Key? key}) {
    return Stack(
      key: key,
      children: [
        Positioned(
          top: 100,
          right: -50,
          child: DecorativeBlob(color: AppColors.accentEmerald, size: 200),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: DecorativeBlob(color: AppColors.brandLight, size: 240),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.accentEmerald.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      size: 80, color: AppColors.accentEmerald),
                ).animate().scale(
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1, 1)),
                const SizedBox(height: 24),
                const Text(
                  'Tạo quiz thành công! 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 8),
                Text(
                  '"$_quizTitle" đã được lưu vào thư viện',
                  style: const TextStyle(color: AppColors.inkSecondary),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GeneratedQuestion {
  final String text;
  final List<_Opt> options;
  _GeneratedQuestion({required this.text, required this.options});
}

class _Opt {
  final String text;
  final bool isCorrect;
  _Opt(this.text, this.isCorrect);
}

/// ======== Helper widgets ========

class _StepIndicator extends StatelessWidget {
  final int current; // 1-based
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i < current;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? AppColors.brandBlue : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceBlue.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brandMid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(20),
    );
    final path = Path()..addRRect(rrect);
    _drawDashedPath(canvas, path, paint, 8, 5);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint,
      double dashWidth, double gapWidth) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      while (dist < metric.length) {
        final next = (dist + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GeneratingHints extends StatefulWidget {
  const _GeneratingHints();
  @override
  State<_GeneratingHints> createState() => _GeneratingHintsState();
}

class _GeneratingHintsState extends State<_GeneratingHints> {
  int _i = 0;
  final hints = const [
    '📖 Đang đọc tài liệu...',
    '🧠 Phân tích nội dung chính',
    '✍️ Soạn câu hỏi',
    '🎯 Tạo đáp án',
  ];

  @override
  void initState() {
    super.initState();
    _tick();
  }

  Future<void> _tick() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _i = (_i + 1) % hints.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Text(
        hints[_i],
        key: ValueKey(_i),
        style: const TextStyle(
          color: AppColors.brandBlue,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

