import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../shared/widgets/themed_card.dart';
import '../data/admin_models.dart';
import '../utils/admin_format.dart';
import '../widgets/admin_ui.dart';
import 'admin_user_detail_screen.dart';

/// C. Chi tiết tài liệu (dữ liệu từ list `documents`).
class AdminDocumentDetailScreen extends ConsumerWidget {
  final AdminDocumentItem doc;
  const AdminDocumentDetailScreen({super.key, required this.doc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final d = doc;
    return AdminDetailScaffold(
      title: 'Chi tiết tài liệu',
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
                  color: t.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.description, size: 26, color: t.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.fileName ?? 'Tài liệu #${d.id}',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: t.ink,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 7),
                    d.isDeleted
                        ? AdminBadge(t: t, label: 'Đã xoá', tone: 'down', icon: Icons.delete_outline)
                        : AdminBadge(t: t, label: 'Đang hoạt động', tone: 'ok', icon: Icons.check),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: AdminStatTile(t: t, icon: Icons.assignment, value: '${d.quizCount}', label: 'Quiz sinh ra', color: t.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AdminStatTile(t: t, icon: Icons.layers, value: '${d.flashcardCount}', label: 'Flashcard sinh ra', color: t.accent),
            ),
          ],
        ),
        AdminGroup(
          t: t,
          label: 'Thông tin',
          child: AdminRows(
            t: t,
            children: [
              AdminInfoRow.text(t, 'Mã tài liệu', '#${d.id}', mono: true),
              AdminInfoRow.text(t, 'Ngày tải lên', fmtDate(d.uploadedAt)),
              AdminInfoRow.text(t, 'Trạng thái', d.isDeleted ? 'Đã xoá mềm' : 'Hoạt động'),
            ],
          ),
        ),
        AdminGroup(
          t: t,
          label: 'Chủ sở hữu',
          child: AdminPersonCard(
            t: t,
            name: d.ownerName,
            email: d.ownerEmail,
            deleted: d.ownerIsDeleted,
            meta: 'Nhấn để xem tài khoản',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AdminUserDetailScreen(userId: d.ownerId),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
