import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../auth/providers/auth_provider.dart';
import '../../quiz/providers/documents_provider.dart';
import '../../quiz/providers/quizzes_provider.dart';
import '../../shared/widgets/ring.dart';
import '../../shared/widgets/section_head.dart';
import '../../shared/widgets/themed_card.dart';

class StudentHomeTab extends ConsumerWidget {
  final VoidCallback onOpenVoice;
  const StudentHomeTab({super.key, required this.onOpenVoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final name = ref.watch(authProvider).displayName ?? 'Bạn';
    // TODO(gamification): thay các giá trị 0 bằng dữ liệu từ /api/UserStats/me
    // khi backend hoàn tất (xem PROGRESS.md sprint Gamification).
    const streak = 0;
    const xp = 0;
    const goalMinutesDone = 0;
    const goalMinutesTarget = 25;
    final goalPct = goalMinutesTarget == 0
        ? 0.0
        : (goalMinutesDone / goalMinutesTarget).clamp(0.0, 1.0);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
      children: [
        // Greeting
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chào buổi sáng,',
                    style: TextStyle(
                      color: t.inkMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$name 👋',
                    style: TextStyle(
                      color: t.ink,
                      fontSize: 22,
                      fontWeight: t.displayWeight,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: t.accentSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department, size: 17, color: t.accent),
                  const SizedBox(width: 4),
                  Text(
                    '$streak',
                    style: TextStyle(
                      color: t.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => ref.read(themeProvider.notifier).toggle(),
              style: IconButton.styleFrom(
                backgroundColor: t.surfaceSunken,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(9),
              ),
              constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
              icon: Icon(
                t.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: t.ink,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: t.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0] : 'M',
                style: TextStyle(
                  color: t.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 16),

        // HERO voice
        GestureDetector(
              onTap: onOpenVoice,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                decoration: BoxDecoration(
                  gradient: t.heroGradient,
                  borderRadius: BorderRadius.circular(t.cardRadius),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x381B3A6B),
                      blurRadius: 34,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -10,
                      right: -28,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -6,
                      bottom: -14,
                      child: Image.asset(
                        'assets/images/mascot-speaking.png',
                        width: 132,
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF34D399),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'Sẵn sàng',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Trò chuyện\ncùng Sumadi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: t.displayWeight,
                              height: 1.2,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hỏi bài bằng giọng nói,\nnghe giảng lại ngay.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mic_rounded,
                                  size: 18,
                                  color: t.primaryDeep,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Bắt đầu nói',
                                  style: TextStyle(
                                    color: t.primaryDeep,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 100.ms, duration: 500.ms)
            .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1)),
        const SizedBox(height: 14),

        // Goal + XP
        Row(
          children: [
            Expanded(
              child: ThemedCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Ring(
                      pct: goalPct,
                      size: 52,
                      stroke: 6,
                      color: t.primary,
                      track: t.surfaceSunken,
                      child: Text(
                        '${(goalPct * 100).round()}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mục tiêu',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: t.ink,
                            ),
                          ),
                          Text(
                            '$goalMinutesDone / $goalMinutesTarget phút',
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
            const SizedBox(width: 12),
            Expanded(
              child: ThemedCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: t.accentSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.bolt, color: t.accent, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$xp',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: t.ink,
                              height: 1,
                            ),
                          ),
                          Text(
                            'điểm XP',
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
          ],
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

        const SizedBox(height: 14),
        _buildContinueLearning(context, ref, t),
        const SizedBox(height: 18),

        SectionHead(
          title: 'Tài liệu của bạn',
          action: '+ Tải lên',
          onAction: () => context.push('/student/upload'),
        ),
        _buildDocsList(context, ref, t),
      ],
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  Widget _buildDocsList(BuildContext context, WidgetRef ref, AppTokens t) {
    final docState = ref.watch(documentsProvider);
    final items = docState.items;

    if (items.isEmpty) {
      return SizedBox(
        height: 168,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              width: 150,
              child: ThemedCard(
                onTap: () => context.push('/student/upload'),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: t.primarySoft,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        Icons.upload_file,
                        color: t.primary,
                        size: 21,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 38,
                      child: Text(
                        'Tải tài liệu lên',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: t.ink,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Chưa có tài liệu',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: t.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: items.length.clamp(0, 5),
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final d = items[i];
          final tint = i % 4;
          return SizedBox(
            width: 150,
            child: ThemedCard(
              onTap: () => context.push('/student/doc-detail?id=${d.id}'),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: t.tints[tint],
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.description,
                      color: t.tintInks[tint],
                      size: 21,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: Text(
                      d.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: t.ink,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatDate(d.uploadedAt),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: t.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContinueLearning(
    BuildContext context,
    WidgetRef ref,
    AppTokens t,
  ) {
    final quizState = ref.watch(quizzesProvider);
    final items = quizState.items;

    if (items.isEmpty) {
      return ThemedCard(
        onTap: () => context.push('/student/upload'),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: t.primarySoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.school, color: t.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bắt đầu bài học đầu tiên',
                    style: TextStyle(
                      color: t.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tải tài liệu lên để Sumadi soạn câu hỏi học tập nhé!',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: t.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, color: t.primary, size: 18),
          ],
        ),
      );
    }

    final q = items.first;
    final tint = q.id % 4;

    return ThemedCard(
      onTap: () => context.push('/student/quiz?quizId=${q.id}'),
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
            child: Icon(Icons.gps_fixed, color: t.tintInks[tint], size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Trạng thái: ${q.status}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: t.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: t.primary, shape: BoxShape.circle),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
