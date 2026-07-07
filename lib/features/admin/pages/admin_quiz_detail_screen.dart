import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../shared/widgets/themed_card.dart';
import '../data/admin_models.dart';
import '../utils/admin_format.dart';
import '../widgets/admin_ui.dart';
import 'admin_user_detail_screen.dart';

/// E. Chi tiết quiz/flashcard (dữ liệu từ list `quizzes`).
/// (Backend `quizzes/{id}` trả metadata — KHÔNG kèm câu hỏi mẫu như prototype.)
class AdminQuizDetailScreen extends ConsumerWidget {
  final AdminQuizItem quiz;
  const AdminQuizDetailScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final q = quiz;
    final isQuiz = q.isQuiz;
    return AdminDetailScaffold(
      title: 'Chi tiết ${isQuiz ? 'quiz' : 'flashcard'}',
      children: [
        ThemedCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isQuiz ? t.primarySoft : t.accentSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isQuiz ? Icons.assignment : Icons.layers,
                  size: 26,
                  color: isQuiz ? t.primary : t.accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: t.ink,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        AdminBadge(t: t, label: q.activityType, tone: isQuiz ? 'primary' : 'accent'),
                        AdminBadge(t: t, label: quizStatusName(q.status), tone: _statusTone(q.status)),
                        if (q.isDeleted) AdminBadge(t: t, label: 'Đã xoá', tone: 'down', icon: Icons.delete_outline),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AdminGroup(
          t: t,
          label: 'Thông tin',
          child: AdminRows(
            t: t,
            children: [
              AdminInfoRow.text(t, 'Mã', '#${q.id}', mono: true),
              AdminInfoRow.text(t, 'Số câu hỏi', '${q.questionCount} câu'),
              AdminInfoRow.text(t, 'Trạng thái', quizStatusName(q.status)),
              AdminInfoRow.text(t, 'Ngày tạo', fmtDate(q.createdAt)),
            ],
          ),
        ),
        AdminGroup(
          t: t,
          label: 'Tài liệu nguồn',
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.primarySoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(Icons.description, size: 20, color: t.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.documentFileName ?? 'Tài liệu #${q.documentId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: t.ink,
                      ),
                    ),
                    Text(
                      '#${q.documentId}${q.documentIsDeleted ? ' · đã xoá' : ''}',
                      style: TextStyle(
                        fontSize: 11,
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
        AdminGroup(
          t: t,
          label: 'Chủ sở hữu',
          child: AdminPersonCard(
            t: t,
            name: q.ownerName,
            email: q.ownerEmail,
            deleted: q.ownerIsDeleted,
            meta: 'Nhấn để xem tài khoản',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AdminUserDetailScreen(userId: q.ownerId),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _statusTone(String s) => switch (s) {
    'Teacher_Approved' => 'primary',
    'Published' => 'ok',
    _ => 'muted',
  };
}
