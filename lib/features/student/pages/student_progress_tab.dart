import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/models/quiz_attempt.dart';
import '../../auth/providers/auth_provider.dart';
import '../../quiz/providers/documents_provider.dart';
import '../../quiz/providers/quizzes_provider.dart';
import '../../quiz/providers/user_stats_provider.dart';
import '../../shared/widgets/section_head.dart';
import '../../shared/widgets/themed_card.dart';

class StudentProgressTab extends ConsumerWidget {
  const StudentProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final name = ref.watch(authProvider).displayName ?? 'Bạn';
    final docCount = ref.watch(documentsProvider).items.length;
    final quizCount = ref.watch(quizzesProvider).items.length;
    final stats = ref.watch(userStatsProvider).valueOrNull;
    final weekAttempts = ref.watch(weekAttemptsProvider).valueOrNull ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
      children: [
        Text(
          'Tiến độ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: t.displayWeight,
            color: t.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),

        // Summary card — dùng data thật từ providers
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: t.heroGradient,
            borderRadius: BorderRadius.circular(t.cardRadius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x331B3A6B),
                blurRadius: 34,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hành trình học cùng Sumadi',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Xin chào $name 👋',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _summaryStat(
                    icon: Icons.bolt,
                    value: '${stats?.xp ?? 0}',
                    label: 'điểm XP',
                  ),
                  Container(
                    width: 1,
                    height: 38,
                    color: Colors.white.withValues(alpha: 0.25),
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  _summaryStat(
                    icon: Icons.local_fire_department,
                    value: '${stats?.effectiveStreak ?? 0}',
                    label: 'ngày streak',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _summaryStat(
                    icon: Icons.description_outlined,
                    value: '$docCount',
                    label: 'tài liệu',
                  ),
                  Container(
                    width: 1,
                    height: 38,
                    color: Colors.white.withValues(alpha: 0.25),
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  _summaryStat(
                    icon: Icons.quiz_outlined,
                    value: '$quizCount',
                    label: 'bộ câu hỏi',
                  ),
                ],
              ),
            ],
          ),
        ),

        const SectionHead(title: 'Tuần này'),
        _WeekChart(attempts: weekAttempts),

        const SectionHead(title: 'Huy hiệu'),
        ThemedCard(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: Column(
            children: [
              Icon(Icons.emoji_events_outlined, color: t.inkMuted, size: 36),
              const SizedBox(height: 10),
              Text(
                'Sắp ra mắt',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: t.ink2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hoàn thành mục tiêu để mở khóa huy hiệu',
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
    );
  }

  Widget _summaryStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bar chart 7 ngày: mỗi cột = số phút học hôm đó (từ Quiz_Attempts).
class _WeekChart extends ConsumerWidget {
  final List<QuizAttemptDto> attempts;
  const _WeekChart({required this.attempts});

  static const _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);

    // Sum phút theo từng ngày của tuần hiện tại (T2 → CN)
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final minutesPerDay = List<int>.filled(7, 0);
    for (final a in attempts) {
      final c = a.completedAt?.toLocal();
      if (c == null) continue;
      final dayIndex = DateTime(c.year, c.month, c.day)
          .difference(monday)
          .inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        minutesPerDay[dayIndex] += a.durationSeconds ~/ 60;
      }
    }
    final maxMinutes =
        minutesPerDay.fold<int>(0, (m, v) => v > m ? v : m);
    final todayIndex = now.weekday - 1;

    if (maxMinutes == 0) {
      return ThemedCard(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Column(
          children: [
            Icon(Icons.insights, color: t.inkMuted, size: 36),
            const SizedBox(height: 10),
            Text(
              'Chưa có hoạt động tuần này',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: t.ink2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hoàn thành một bộ câu hỏi để bắt đầu!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: t.inkMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ThemedCard(
      child: SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final pct = maxMinutes == 0 ? 0.0 : minutesPerDay[i] / maxMinutes;
            final isToday = i == todayIndex;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (minutesPerDay[i] > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${minutesPerDay[i]}p',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: t.inkMuted,
                          ),
                        ),
                      ),
                    Container(
                      height: pct * 64 + 6,
                      width: 22,
                      decoration: BoxDecoration(
                        color: isToday ? t.accent : t.primary,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _dayLabels[i],
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight:
                            isToday ? FontWeight.w800 : FontWeight.w700,
                        color: isToday ? t.accent : t.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
