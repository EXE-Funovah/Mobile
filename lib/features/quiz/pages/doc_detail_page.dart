import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../data/models/document.dart';
import '../../shared/widgets/flow_header.dart';
import '../../shared/widgets/themed_card.dart';
import '../providers/documents_provider.dart';

class DocDetailPage extends ConsumerWidget {
  final int? documentId;
  const DocDetailPage({super.key, this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);

    if (documentId == null) {
      return _scaffold(
        context,
        t,
        title: 'Tài liệu',
        subtitle: 'Không tìm thấy',
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Thiếu mã tài liệu trong đường dẫn.'),
          ),
        ),
      );
    }

    final async = ref.watch(documentByIdProvider(documentId!));
    return async.when(
      loading: () => _scaffold(
        context,
        t,
        title: 'Đang tải…',
        subtitle: '',
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => _scaffold(
        context,
        t,
        title: 'Tài liệu',
        subtitle: 'Lỗi',
        body: Padding(
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
                onPressed: () => ref.refresh(documentByIdProvider(documentId!)),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
      data: (doc) => _DocDetailView(doc: doc),
    );
  }

  Widget _scaffold(
    BuildContext context,
    AppTokens t, {
    required String title,
    required String subtitle,
    required Widget body,
  }) {
    return Scaffold(
      backgroundColor: t.appBg,
      body: SafeArea(
        child: Column(
          children: [
            FlowHeader(
              title: title,
              subtitle: subtitle,
              onBack: () => context.pop(),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _DocDetailView extends ConsumerWidget {
  final DocumentDto doc;
  const _DocDetailView({required this.doc});

  Future<void> _openExternal(BuildContext context) async {
    final uri = Uri.tryParse(doc.presignedUrl);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL tài liệu không hợp lệ')),
      );
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể mở tài liệu')));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tài liệu?'),
        content: Text(
          '${doc.displayName}\n\nTài liệu và các bộ câu hỏi của nó sẽ bị xóa.',
        ),
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
    if (ok != true || !context.mounted) return;
    await ref.read(documentsProvider.notifier).remove(doc.id);
    if (!context.mounted) return;
    final err = ref.read(documentsProvider).error;
    if (err != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xóa thất bại: $err')));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xóa tài liệu')));
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final uploaded = doc.uploadedAt?.toLocal();
    final dateStr = uploaded == null
        ? '—'
        : '${uploaded.day.toString().padLeft(2, '0')}/'
              '${uploaded.month.toString().padLeft(2, '0')}/${uploaded.year}';

    return Scaffold(
      backgroundColor: t.appBg,
      body: SafeArea(
        child: Column(
          children: [
            FlowHeader(
              title: doc.displayName,
              subtitle: 'Đã tải lên · $dateStr',
              onBack: () => context.pop(),
              trailing: Material(
                color: t.surface,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => _confirmDelete(context, ref),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      border: t.cardBorder,
                      boxShadow: t.cardShadow,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.delete_outline,
                      size: 19,
                      color: t.danger,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                children: [
                  // Thumbnail
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: t.heroGradient,
                      borderRadius: BorderRadius.circular(t.cardRadius),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.description_outlined,
                        size: 84,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Thông tin tài liệu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: t.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ThemedCard(
                    child: Column(
                      children: [
                        _row(t, Icons.tag, 'Mã', '#${doc.id}'),
                        const SizedBox(height: 10),
                        _row(t, Icons.calendar_today, 'Ngày tải', dateStr),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _openExternal(context),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: t.cardBorder,
                          boxShadow: t.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: t.primarySoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.open_in_new,
                                color: t.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mở tài liệu',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: t.ink,
                                    ),
                                  ),
                                  Text(
                                    'Xem trên trình duyệt qua đường dẫn S3',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: t.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: t.inkMuted),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Sticky CTA — vẫn cho phép vào quiz nếu user muốn (sẽ nối với API câu hỏi sau)
            Container(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
              decoration: BoxDecoration(
                color: t.appBg,
                border: Border(top: BorderSide(color: t.line)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: _GradientButton(
                  onPressed: () =>
                      context.go('/student/quiz?documentId=${doc.id}'),
                  gradient: t.fabGradient,
                  shadowColor: t.fabRing,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.play_arrow_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Làm câu hỏi mẫu',
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
        ),
      ),
    );
  }

  Widget _row(
    AppTokens t,
    IconData icon,
    String label,
    String value, {
    bool multiline = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: t.inkMuted, size: 18),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              color: t.inkMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: multiline ? 3 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: t.ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
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
