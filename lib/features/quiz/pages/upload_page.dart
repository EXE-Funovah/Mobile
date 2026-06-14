import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../data/api/document_api.dart';
import '../../../data/api/ai_api.dart';
import '../../shared/widgets/flow_header.dart';
import '../../shared/widgets/themed_card.dart';
import '../providers/documents_provider.dart';
import 'quiz_preview_page.dart';

enum _UploadStatus { idle, processing, error }

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  _UploadStatus _status = _UploadStatus.idle;
  int _step = 0;
  String? _fileName;
  int? _fileSize;
  String? _errorMsg;

  final _steps = const [
    (icon: Icons.scanner, t: 'Tải tệp lên', d: 'Đang gửi tới máy chủ'),
    (icon: Icons.description, t: 'Lưu metadata', d: 'Ghi nhận tài liệu'),
    (
      icon: Icons.auto_awesome,
      t: 'Tạo câu hỏi',
      d: 'Sumadi đang soạn câu hỏi…',
    ),
  ];

  Future<void> _start() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'docx',
        'doc',
        'pptx',
        'png',
        'jpg',
        'jpeg',
      ],
      withData: kIsWeb,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    if (!mounted) return;

    setState(() {
      _fileName = file.name;
      _fileSize = file.size;
      _step = 0;
      _status = _UploadStatus.processing;
      _errorMsg = null;
    });

    try {
      // Đọc bytes file gốc (web có sẵn bytes, mobile đọc từ path)
      final rawBytes =
          file.bytes ??
          (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (rawBytes == null) {
        throw Exception('Không đọc được nội dung file.');
      }

      // Nén thành zip — backend chỉ ký presigned URL cho application/zip,
      // PUT file thô sẽ bị S3 403 (lệch chữ ký).
      final zipped = DocumentApi.zipSingleFile(
        fileName: file.name,
        bytes: rawBytes,
      );

      // Step 1 — presign + PUT S3
      final presign = await DocumentApi.instance.generateUploadUrl(
        fileName: file.name,
        contentType: 'application/zip',
      );
      await DocumentApi.instance.putToS3(
        uploadUrl: presign.uploadUrl,
        contentType: 'application/zip',
        bytes: zipped,
      );
      if (!mounted) return;
      setState(() => _step = 1);

      // Step 2 — create document (kèm tên gốc để hiển thị đẹp)
      final created = await DocumentApi.instance.createFromS3Key(
        presign.s3Key,
        fileName: file.name,
      );
      ref.read(documentsProvider.notifier).addOptimistic(created);
      if (!mounted) return;
      setState(() => _step = 2);

      // Step 3 — AI soạn câu hỏi. CHƯA lưu — giáo viên xem trước rồi mới
      // bấm Xuất bản (giống web: quiz chỉ tạo khi publish, status Teacher_Approved).
      final quizTitle = 'Trắc nghiệm: ${created.displayName}';
      final questions = await AiApi.instance.generateQuestions(
        fileUrl: created.presignedUrl,
        documentId: created.id,
        quizTitle: quizTitle,
        numberOfQuestions: 5,
        difficulty: 'Vừa',
      );
      if (!mounted) return;
      context.pushReplacement(
        '/student/quiz-preview',
        extra: QuizPreviewArgs(
          documentId: created.id,
          quizTitle: quizTitle,
          questions: questions,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _UploadStatus.error;
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
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
              title: 'Tải tài liệu',
              subtitle: 'Biến bài học thành câu hỏi',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
                child: _buildContent(t),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppTokens t) {
    switch (_status) {
      case _UploadStatus.idle:
        return _idleView(t);
      case _UploadStatus.processing:
        return _processingView(t);
      case _UploadStatus.error:
        return _errorView(t);
    }
  }

  Widget _errorView(AppTokens t) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: t.danger, size: 64),
          const SizedBox(height: 12),
          Text(
            'Tải lên thất bại',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: t.ink,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMsg ?? 'Có lỗi xảy ra. Vui lòng thử lại.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.ink2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _status = _UploadStatus.idle;
              _errorMsg = null;
              _fileName = null;
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _idleView(AppTokens t) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drop zone
            GestureDetector(
              onTap: _start,
              child: DottedBorderBox(
                color: t.line,
                radius: t.cardRadius,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 34,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(t.cardRadius),
                    boxShadow: t.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: t.primarySoft,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: 36,
                          color: t.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Kéo tệp vào đây',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'PDF, ảnh hoặc chụp trang sách',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: t.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _quickBtn(
                    t,
                    Icons.camera_alt,
                    'Chụp ảnh',
                    'Dùng camera',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _quickBtn(
                    t,
                    Icons.description,
                    'Chọn tệp',
                    'Từ thiết bị',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
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
                        children: [
                          TextSpan(
                            text: 'Mẹo: ',
                            style: TextStyle(
                              color: t.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Ảnh càng rõ nét, Sumadi tạo câu hỏi càng chính xác nhé!',
                            style: TextStyle(
                              color: t.ink2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 12.5, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
        .animate()
        .scale(
          duration: 350.ms,
          curve: Curves.easeOut,
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
        )
        .fadeIn(duration: 250.ms);
  }

  Widget _quickBtn(AppTokens t, IconData icon, String title, String desc) {
    return GestureDetector(
      onTap: _start,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: t.cardShadow,
          border: t.cardBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: t.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 21, color: t.accent),
            ),
            const SizedBox(height: 9),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: t.ink,
              ),
            ),
            Text(
              desc,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: t.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _processingView(AppTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ThemedCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: t.tints[0],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.description, color: t.tintInks[0], size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fileName ?? 'Đang chuẩn bị…',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: t.ink,
                      ),
                    ),
                    Text(
                      _fileSize != null
                          ? '${(_fileSize! / 1024 / 1024).toStringAsFixed(2)} MB'
                          : '—',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: t.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [t.primarySoft, Colors.transparent],
                      stops: const [0, 0.7],
                    ),
                  ),
                ),
                Image.asset('assets/images/mascot-speaking.png', width: 132)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(duration: 2400.ms, begin: 0, end: -8),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Đang phân tích tài liệu…',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: t.ink,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(_steps.length, (k) {
          final doneStep = k < _step;
          final active = k == _step;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                color: active ? t.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: active ? t.cardShadow : null,
              ),
              child: Opacity(
                opacity: doneStep || active ? 1 : 0.45,
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: doneStep
                            ? t.ok
                            : active
                            ? t.primary
                            : t.surfaceSunken,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(
                        child: doneStep
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              )
                            : active
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Icon(_steps[k].icon, color: t.inkMuted, size: 19),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _steps[k].t,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: t.ink,
                            ),
                          ),
                          Text(
                            doneStep ? 'Hoàn tất' : _steps[k].d,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: t.inkMuted,
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
        }),
      ],
    ).animate().fadeIn(duration: 350.ms);
  }
}

/// Dotted border container (border 2px dashed, radius variable).
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  const DottedBorderBox({
    super.key,
    required this.child,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double d = 0;
      while (d < m.length) {
        final n = (d + 8).clamp(0, m.length).toDouble();
        canvas.drawPath(m.extractPath(d, n), paint);
        d = n + 5;
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
