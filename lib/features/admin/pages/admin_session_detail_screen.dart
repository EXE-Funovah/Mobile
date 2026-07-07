import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../shared/widgets/themed_card.dart';
import '../data/admin_models.dart';
import '../providers/admin_providers.dart';
import '../utils/admin_format.dart';
import '../widgets/admin_ui.dart';
import 'admin_user_detail_screen.dart';

/// G. Chi tiết phiên live + bảng xếp hạng người tham gia.
class AdminSessionDetailScreen extends ConsumerWidget {
  final AdminSessionItem session;
  const AdminSessionDetailScreen({super.key, required this.session});

  static const _medal = [Color(0xFFF4B740), Color(0xFFB8C2D0), Color(0xFFCD8A54)];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final s = session;
    final partAsync = ref.watch(adminParticipantsProvider(s.id));

    return AdminDetailScaffold(
      title: 'Chi tiết phiên',
      children: [
        // Header PIN
        ThemedCard(
          child: Column(
            children: [
              Text(
                'GAME PIN',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: t.inkMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s.gamePin,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  height: 1.1,
                  color: t.primary,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  AdminBadge(
                    t: t,
                    label: sessStatusName(s.status),
                    tone: _sessTone(s.status),
                    icon: s.status == 'Active'
                        ? Icons.bolt
                        : s.status == 'Waiting'
                        ? Icons.schedule
                        : Icons.check,
                  ),
                  AdminBadge(t: t, label: '${s.participantCount} người chơi', tone: 'primary', icon: Icons.people),
                ],
              ),
            ],
          ),
        ),
        AdminGroup(
          t: t,
          label: 'Thông tin phiên',
          child: AdminRows(
            t: t,
            children: [
              AdminInfoRow.text(t, 'Quiz', s.quizTitle),
              AdminInfoRow.text(t, 'Loại', s.quizActivityType),
              AdminInfoRow.text(t, 'Template', s.templateName),
              AdminInfoRow.text(t, 'Bắt đầu', fmtDateTime(s.createdAt)),
            ],
          ),
        ),
        AdminGroup(
          t: t,
          label: 'Giáo viên',
          child: AdminPersonCard(
            t: t,
            name: s.teacherName,
            email: s.teacherEmail,
            color: t.accent,
            deleted: s.teacherIsDeleted,
            meta: 'Nhấn để xem tài khoản',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AdminUserDetailScreen(userId: s.teacherId),
              ),
            ),
          ),
        ),
        // Bảng xếp hạng
        partAsync.when(
          loading: () => AdminAsyncSlivers.loading(),
          error: (e, _) => AdminAsyncSlivers.error(
            t,
            e,
            () => ref.invalidate(adminParticipantsProvider(s.id)),
          ),
          data: (p) => _leaderboard(t, p),
        ),
      ],
    );
  }

  Widget _leaderboard(AppTokens t, AdminParticipants p) {
    final ranked = [...p.items]
      ..sort((a, b) => (b.totalScore ?? 0).compareTo(a.totalScore ?? 0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminSectionLabel(
          t: t,
          label: 'Bảng xếp hạng',
          trailing: Text(
            '${ranked.length} người',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: t.inkMuted,
            ),
          ),
        ),
        ThemedCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: ranked.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Chưa có người tham gia.',
                      style: TextStyle(color: t.inkMuted),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < ranked.length; i++) ...[
                      if (i > 0) Divider(height: 1, color: t.line),
                      _rankRow(t, i, ranked[i]),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _rankRow(AppTokens t, int i, AdminParticipant p) {
    final top3 = i < 3;
    final medalColor = top3 ? _medal[i] : t.inkMuted;
    return Opacity(
      opacity: p.isDeleted ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: top3
                    ? medalColor.withValues(alpha: 0.15)
                    : t.surfaceSunken,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: top3 ? medalColor : t.inkMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      p.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: t.ink,
                      ),
                    ),
                  ),
                  if (p.isDeleted) ...[
                    const SizedBox(width: 7),
                    AdminBadge(t: t, label: 'Đã xoá', tone: 'down'),
                  ],
                ],
              ),
            ),
            Text(
              vnd(p.totalScore ?? 0),
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: i == 0 ? t.accent : t.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sessTone(String s) => switch (s) {
    'Active' => 'ok',
    'Waiting' => 'accent',
    _ => 'muted',
  };
}
