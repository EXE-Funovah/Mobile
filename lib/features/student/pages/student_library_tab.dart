import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../data/models/document.dart';
import '../../quiz/providers/documents_provider.dart';
import '../../quiz/providers/quizzes_provider.dart';
import '../../shared/widgets/themed_card.dart';

class StudentLibraryTab extends ConsumerStatefulWidget {
  const StudentLibraryTab({super.key});
  @override
  ConsumerState<StudentLibraryTab> createState() => _StudentLibraryTabState();
}

class _StudentLibraryTabState extends ConsumerState<StudentLibraryTab> {
  String _tab = 'docs';

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
      children: [
        Text(
          'Thư viện',
          style: TextStyle(
            fontSize: 24,
            fontWeight: t.displayWeight,
            color: t.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 14),
        // Search
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: t.cardShadow,
            border: t.cardBorder,
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 19, color: t.inkMuted),
              const SizedBox(width: 10),
              Text(
                'Tìm tài liệu, câu hỏi…',
                style: TextStyle(
                  color: t.inkMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: t.surfaceSunken,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              _tabBtn('docs', 'Tài liệu', t),
              const SizedBox(width: 6),
              _tabBtn('quiz', 'Câu hỏi', t),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_tab == 'docs') ..._docsList(t) else ..._quizList(t),
      ],
    );
  }

  Widget _tabBtn(String id, String label, AppTokens t) {
    final active = _tab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? t.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active ? t.cardShadow : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? t.primary : t.inkMuted,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _docsList(AppTokens t) {
    final docState = ref.watch(documentsProvider);
    return [
      // upload prompt
      GestureDetector(
        onTap: () => context.push('/student/upload'),
        child: CustomPaint(
          painter: _DashedPainter(color: t.line, radius: t.cardRadius),
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: t.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.upload_file, color: t.primary, size: 22),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tải tài liệu lên',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                        ),
                      ),
                      Text(
                        'PDF, DOCX, PPTX hoặc ảnh',
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
        ),
      ),
      const SizedBox(height: 11),
      if (docState.loading && docState.items.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (docState.error != null && docState.items.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.cloud_off, color: t.inkMuted, size: 38),
              const SizedBox(height: 8),
              Text(
                docState.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: t.ink2, fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => ref.read(documentsProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        )
      else if (docState.items.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              Icon(Icons.folder_open, color: t.inkMuted, size: 38),
              const SizedBox(height: 8),
              Text(
                'Chưa có tài liệu nào',
                style: TextStyle(
                  color: t.ink2,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Tải lên tài liệu đầu tiên để bắt đầu',
                style: TextStyle(color: t.inkMuted, fontSize: 12),
              ),
            ],
          ),
        )
      else
        ...List.generate(docState.items.length, (i) {
          final d = docState.items[i];
          final tint = i % 4;
          return Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: ThemedCard(
              onTap: () => context.push('/student/doc-detail?id=${d.id}'),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: t.tints[tint],
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.description,
                      color: t.tintInks[tint],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: t.ink,
                            height: 1.3,
                          ),
                        ),
                        Text(
                          _formatDate(d.uploadedAt),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: t.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(d),
                    icon: Icon(
                      Icons.delete_outline,
                      color: t.inkMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
    ];
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  Future<void> _confirmDelete(DocumentDto d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tài liệu?'),
        content: Text(d.displayName),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(documentsProvider.notifier).remove(d.id);
    }
  }

  List<Widget> _quizList(AppTokens t) {
    final quizState = ref.watch(quizzesProvider);

    if (quizState.loading && quizState.items.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (quizState.error != null && quizState.items.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.cloud_off, color: t.inkMuted, size: 38),
              const SizedBox(height: 8),
              Text(
                quizState.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: t.ink2, fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => ref.read(quizzesProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ];
    }

    if (quizState.items.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              Icon(Icons.assignment_outlined, color: t.inkMuted, size: 38),
              const SizedBox(height: 8),
              Text(
                'Chưa có bộ câu hỏi nào',
                style: TextStyle(
                  color: t.ink2,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Tải tài liệu lên để tự động tạo câu hỏi trắc nghiệm',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.inkMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ];
    }

    return quizState.items.map((q) {
      final tint = q.id % 4;
      return Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: ThemedCard(
          onTap: () => context.push('/student/quiz?quizId=${q.id}'),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: t.tints[tint],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.gps_fixed,
                      color: t.tintInks[tint],
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: t.ink,
                          ),
                        ),
                        Text(
                          'Trạng thái: ${q.status}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: t.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: t.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class _DashedPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedPainter({required this.color, required this.radius});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
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
