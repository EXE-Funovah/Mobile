import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/themed_card.dart';
import '../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../utils/admin_format.dart';
import '../widgets/admin_ui.dart';
import 'admin_document_detail_screen.dart';
import 'admin_quiz_detail_screen.dart';
import 'admin_session_detail_screen.dart';

/// Tab "Nội dung" — segmented: Tài liệu (B) · Quiz/Flashcard (D) · Phiên live (F).
class AdminContentTab extends ConsumerStatefulWidget {
  const AdminContentTab({super.key});

  @override
  ConsumerState<AdminContentTab> createState() => _AdminContentTabState();
}

class _AdminContentTabState extends ConsumerState<AdminContentTab> {
  final _searchCtl = TextEditingController();

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  static const _delLabels = ['Đang hoạt động', 'Đã xoá', 'Tất cả'];
  static const _delValues = ['Active', 'Deleted', 'All'];

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    final seg = ref.watch(adminContentSegProvider);
    final hint = switch (seg) {
      0 => 'Tìm theo tên tài liệu, chủ sở hữu…',
      1 => 'Tìm theo tiêu đề, chủ sở hữu…',
      _ => 'Tìm theo mã PIN, giáo viên…',
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      children: [
        AdminSeg(
          t: t,
          items: const ['Tài liệu', 'Quiz · Flashcard', 'Phiên live'],
          active: seg,
          onChange: (i) => ref.read(adminContentSegProvider.notifier).state = i,
        ),
        const SizedBox(height: 12),
        AdminSearchField(
          t: t,
          hint: hint,
          controller: _searchCtl,
          onSubmit: (v) =>
              ref.read(adminContentSearchProvider.notifier).state = v,
        ),
        const SizedBox(height: 12),
        if (seg == 0) ..._documents(t) else if (seg == 1) ..._quizzes(t) else ..._sessions(t),
      ],
    );
  }

  // ── B. Documents ──
  List<Widget> _documents(AppTokens t) {
    final del = ref.watch(adminContentDeletionProvider);
    final async = ref.watch(adminDocumentsProvider);
    return [
      AdminChips(
        t: t,
        labels: _delLabels,
        values: _delValues,
        selected: del,
        onSelect: (v) =>
            ref.read(adminContentDeletionProvider.notifier).state = v!,
      ),
      const SizedBox(height: 12),
      async.when(
        loading: () => AdminAsyncSlivers.loading(),
        error: (e, _) => AdminAsyncSlivers.error(t, e, () => ref.invalidate(adminDocumentsProvider)),
        data: (d) => Column(
          children: [
            if (d.items.isEmpty)
              _empty(t, 'Không có tài liệu nào.')
            else
              ...d.items.map((doc) => _docCard(t, doc)),
            AdminAsyncSlivers.footer(t, d.items.length, d.total),
          ],
        ),
      ),
    ];
  }

  Widget _docCard(AppTokens t, AdminDocumentItem d) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: d.isDeleted ? 0.72 : 1,
        child: ThemedCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AdminDocumentDetailScreen(doc: d)),
          ),
          padding: const EdgeInsets.all(13),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _iconChip(t, Icons.description, t.primary, t.primarySoft),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                d.fileName ?? 'Tài liệu #${d.id}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: t.ink),
                              ),
                            ),
                            if (d.isDeleted) AdminBadge(t: t, label: 'Đã xoá', tone: 'down', icon: Icons.delete_outline),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _ownerLine(t, d.ownerName, d.ownerIsDeleted),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: t.inkMuted),
                ],
              ),
              _cardFooter(t, [
                _stat(t, Icons.assignment, d.quizCount, 'quiz'),
                _stat(t, Icons.layers, d.flashcardCount, 'flashcard'),
              ], fmtDate(d.uploadedAt)),
            ],
          ),
        ),
      ),
    );
  }

  // ── D. Quizzes ──
  List<Widget> _quizzes(AppTokens t) {
    final del = ref.watch(adminContentDeletionProvider);
    final act = ref.watch(adminQuizActivityProvider);
    final status = ref.watch(adminQuizStatusProvider);
    final async = ref.watch(adminQuizzesProvider);
    return [
      AdminSeg(
        t: t,
        items: const ['Tất cả', 'Quiz', 'Flashcard'],
        active: act == null ? 0 : (act == 'Quiz' ? 1 : 2),
        onChange: (i) => ref.read(adminQuizActivityProvider.notifier).state =
            i == 0 ? null : (i == 1 ? 'Quiz' : 'Flashcard'),
      ),
      const SizedBox(height: 10),
      AdminChips(
        t: t,
        labels: const ['Mọi trạng thái', 'AI nháp', 'GV duyệt', 'Đã xuất bản', 'Đã xoá'],
        values: const [null, 'AI_Drafted', 'Teacher_Approved', 'Published', '__deleted'],
        selected: del == 'Deleted' ? '__deleted' : status,
        onSelect: (v) {
          if (v == '__deleted') {
            ref.read(adminContentDeletionProvider.notifier).state = 'Deleted';
            ref.read(adminQuizStatusProvider.notifier).state = null;
          } else {
            ref.read(adminContentDeletionProvider.notifier).state = 'Active';
            ref.read(adminQuizStatusProvider.notifier).state = v;
          }
        },
      ),
      const SizedBox(height: 12),
      async.when(
        loading: () => AdminAsyncSlivers.loading(),
        error: (e, _) => AdminAsyncSlivers.error(t, e, () => ref.invalidate(adminQuizzesProvider)),
        data: (d) => Column(
          children: [
            if (d.items.isEmpty)
              _empty(t, 'Không có bộ nào.')
            else
              ...d.items.map((q) => _quizCard(t, q)),
            AdminAsyncSlivers.footer(t, d.items.length, d.total),
          ],
        ),
      ),
    ];
  }

  Widget _quizCard(AppTokens t, AdminQuizItem q) {
    final isQuiz = q.isQuiz;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: q.isDeleted ? 0.72 : 1,
        child: ThemedCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AdminQuizDetailScreen(quiz: q)),
          ),
          padding: const EdgeInsets.all(13),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _iconChip(
                    t,
                    isQuiz ? Icons.assignment : Icons.layers,
                    isQuiz ? t.primary : t.accent,
                    isQuiz ? t.primarySoft : t.accentSoft,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: t.ink),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            AdminBadge(t: t, label: q.activityType, tone: isQuiz ? 'primary' : 'accent'),
                            AdminBadge(t: t, label: quizStatusName(q.status), tone: _quizTone(q.status)),
                            if (q.isDeleted) AdminBadge(t: t, label: 'Đã xoá', tone: 'down', icon: Icons.delete_outline),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: t.inkMuted),
                ],
              ),
              _cardFooter(t, [
                _stat(t, Icons.check, q.questionCount, 'câu'),
              ], q.documentFileName ?? '#${q.documentId}', footIcon: Icons.description),
            ],
          ),
        ),
      ),
    );
  }

  // ── F. Sessions ──
  List<Widget> _sessions(AppTokens t) {
    final del = ref.watch(adminContentDeletionProvider);
    final status = ref.watch(adminSessStatusProvider);
    final async = ref.watch(adminSessionsProvider);
    return [
      AdminChips(
        t: t,
        labels: const ['Tất cả', 'Chờ', 'Đang chạy', 'Kết thúc', 'Đã xoá'],
        values: const [null, 'Waiting', 'Active', 'Ended', '__deleted'],
        selected: del == 'Deleted' ? '__deleted' : status,
        onSelect: (v) {
          if (v == '__deleted') {
            ref.read(adminContentDeletionProvider.notifier).state = 'Deleted';
            ref.read(adminSessStatusProvider.notifier).state = null;
          } else {
            ref.read(adminContentDeletionProvider.notifier).state = 'Active';
            ref.read(adminSessStatusProvider.notifier).state = v;
          }
        },
      ),
      const SizedBox(height: 12),
      async.when(
        loading: () => AdminAsyncSlivers.loading(),
        error: (e, _) => AdminAsyncSlivers.error(t, e, () => ref.invalidate(adminSessionsProvider)),
        data: (d) => Column(
          children: [
            if (d.items.isEmpty)
              _empty(t, 'Không có phiên nào.')
            else
              ...d.items.map((s) => _sessionCard(t, s)),
            AdminAsyncSlivers.footer(t, d.items.length, d.total),
          ],
        ),
      ),
    ];
  }

  Widget _sessionCard(AppTokens t, AdminSessionItem s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: s.isDeleted ? 0.72 : 1,
        child: ThemedCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AdminSessionDetailScreen(session: s)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 74,
                    child: Column(
                      children: [
                        Text(
                          'GAME PIN',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: t.inkMuted),
                        ),
                        Text(
                          s.gamePin,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: t.primary, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: t.line),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AdminBadge(
                              t: t,
                              label: sessStatusName(s.status),
                              tone: _sessTone(s.status),
                              icon: s.status == 'Active' ? Icons.bolt : s.status == 'Waiting' ? Icons.schedule : Icons.check,
                            ),
                            if (s.isDeleted) ...[
                              const SizedBox(width: 6),
                              AdminBadge(t: t, label: 'Đã xoá', tone: 'down'),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.quizTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: t.ink),
                        ),
                        Text(
                          '${s.teacherName} · ${s.templateName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: t.inkMuted),
                ],
              ),
              _cardFooter(t, [
                _stat(t, Icons.people, s.participantCount, 'người chơi'),
              ], fmtDateTime(s.createdAt), footIcon: Icons.schedule),
            ],
          ),
        ),
      ),
    );
  }

  // ── helpers ──
  Widget _iconChip(AppTokens t, IconData icon, Color fg, Color bg) => Container(
    width: 40,
    height: 40,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
    child: Icon(icon, size: 20, color: fg),
  );

  Widget _ownerLine(AppTokens t, String name, bool deleted) => Row(
    children: [
      AdminAvatar(name: name, color: t.primary, size: 22),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: t.ink2),
        ),
      ),
      if (deleted) ...[
        const SizedBox(width: 7),
        AdminBadge(t: t, label: 'Chủ đã xoá', tone: 'down'),
      ],
    ],
  );

  Widget _cardFooter(AppTokens t, List<Widget> stats, String trailing, {IconData footIcon = Icons.calendar_today}) {
    return Container(
      margin: const EdgeInsets.only(top: 11),
      padding: const EdgeInsets.only(top: 11),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: t.line))),
      child: Row(
        children: [
          for (final s in stats) ...[s, const SizedBox(width: 16)],
          const Spacer(),
          Icon(footIcon, size: 13, color: t.inkMuted),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              trailing,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.inkMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(AppTokens t, IconData icon, int value, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: t.inkMuted),
      const SizedBox(width: 5),
      Text('$value', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: t.ink)),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontSize: 11, color: t.inkMuted)),
    ],
  );

  Widget _empty(AppTokens t, String msg) => Padding(
    padding: const EdgeInsets.only(top: 40),
    child: Center(child: Text(msg, style: TextStyle(color: t.inkMuted))),
  );

  String _quizTone(String s) => switch (s) {
    'Teacher_Approved' => 'primary',
    'Published' => 'ok',
    _ => 'muted',
  };
  String _sessTone(String s) => switch (s) {
    'Active' => 'ok',
    'Waiting' => 'accent',
    _ => 'muted',
  };
}
