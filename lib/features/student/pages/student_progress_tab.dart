import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../data/models/quiz_attempt.dart';
import '../../auth/providers/auth_provider.dart';
import '../../quiz/providers/documents_provider.dart';
import '../../quiz/providers/quizzes_provider.dart';
import '../../../data/models/user_stats.dart';
import '../../quiz/providers/user_stats_provider.dart';
import '../../shared/widgets/ring.dart';
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

        ..._buildBadges(t, stats, docCount, quizCount),
      ],
    );
  }

  /// Huy hiệu suy ra từ chỉ số học tập thật — earned khi val ≥ target.
  /// Khớp design screens.jsx (8 huy hiệu, card "Sắp mở khoá" + grid 2 cột).
  List<Widget> _buildBadges(
    AppTokens t,
    UserStatsDto? stats,
    int docCount,
    int quizCount,
  ) {
    final badges = <_Badge>[
      _Badge(Icons.auto_awesome, 'Khởi đầu', 0, quizCount, 1, 'quiz'),
      _Badge(
        Icons.local_fire_department,
        'Streak rực lửa',
        1,
        stats?.effectiveStreak ?? 0,
        7,
        'ngày',
      ),
      _Badge(
        Icons.gps_fixed,
        'Thiện xạ',
        2,
        stats?.totalCorrectAnswers ?? 0,
        100,
        'câu',
      ),
      _Badge(
        Icons.mic,
        'Giọng vàng',
        3,
        stats?.totalLearningMinutes ?? 0,
        60,
        'phút',
      ),
      _Badge(
        Icons.star,
        'Siêu chính xác',
        3,
        (stats?.accuracyPercent ?? 0).round(),
        95,
        '%',
      ),
      _Badge(
        Icons.workspace_premium,
        'Cao thủ',
        2,
        stats?.level ?? 1,
        10,
        'cấp',
      ),
      _Badge(Icons.bolt, 'Bậc thầy XP', 1, stats?.xp ?? 0, 2000, 'XP'),
      _Badge(Icons.description, 'Nhà sưu tầm', 0, docCount, 10, 'tài liệu'),
    ];
    final earned = badges.where((b) => b.on).length;
    final locked = badges.where((b) => !b.on).toList()
      ..sort((a, b) => b.pct.compareTo(a.pct));
    final next = locked.isNotEmpty ? locked.first : null;

    return [
      SectionHead(title: 'Huy hiệu', action: '$earned/${badges.length} đã mở'),
      if (next != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ThemedCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _BadgeMedallion(badge: next, size: 66),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SẮP MỞ KHOÁ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: t.accent,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        next.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                        ),
                      ),
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: next.pct,
                          minHeight: 7,
                          backgroundColor: t.surfaceSunken,
                          valueColor: AlwaysStoppedAnimation(t.accent),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_vn(next.val)}/${_vn(next.target)} ${next.unit} · còn ${_vn(next.target - next.val)} ${next.unit} nữa',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 11,
        crossAxisSpacing: 11,
        childAspectRatio: 2.5,
        children: badges
            .map(
              (b) => ThemedCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _BadgeMedallion(badge: b, size: 50),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: t.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            b.on
                                ? 'Đã mở khoá'
                                : '${_vn(b.val)}/${_vn(b.target)} ${b.unit}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: b.on ? t.accent : t.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    ];
  }

  /// Format số kiểu vi-VN (dấu chấm ngăn nghìn): 1240 → "1.240".
  static String _vn(int n) {
    final s = n.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return (n < 0 ? '-' : '') + buf.toString();
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

/// Một huy hiệu: earned (`on`) khi val ≥ target; `pct` = tiến độ 0..1.
class _Badge {
  final IconData icon;
  final String title;
  final int tint;
  final int val;
  final int target;
  final String unit;

  const _Badge(
    this.icon,
    this.title,
    this.tint,
    this.val,
    this.target,
    this.unit,
  );

  bool get on => val >= target;
  double get pct => target == 0 ? 1 : (val / target).clamp(0.0, 1.0);
}

/// Medallion: ring tiến độ + icon (hoặc khóa nếu chưa đạt) + seal khi đã mở.
class _BadgeMedallion extends ConsumerWidget {
  final _Badge badge;
  final double size;
  const _BadgeMedallion({required this.badge, this.size = 58});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final stroke = 4.0;
    final inner = size - stroke * 2 - 6;
    final tintBg = badge.on ? t.tints[badge.tint] : t.surfaceSunken;
    final tintInk = badge.on ? t.tintInks[badge.tint] : t.inkMuted;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Ring(
            pct: badge.on ? 1 : badge.pct,
            size: size,
            stroke: stroke,
            color: badge.on ? t.accent : t.primary,
            track: t.surfaceSunken,
            child: Container(
              width: inner,
              height: inner,
              decoration: BoxDecoration(color: tintBg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(
                badge.on ? badge.icon : Icons.lock,
                size: size * 0.4,
                color: tintInk,
              ),
            ),
          ),
          if (badge.on)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: t.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.surface, width: 2.5),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.check, size: 11, color: Colors.white),
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
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final minutesPerDay = List<int>.filled(7, 0);
    for (final a in attempts) {
      final c = a.completedAt?.toLocal();
      if (c == null) continue;
      final dayIndex = DateTime(
        c.year,
        c.month,
        c.day,
      ).difference(monday).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        minutesPerDay[dayIndex] += a.durationSeconds ~/ 60;
      }
    }
    final maxMinutes = minutesPerDay.fold<int>(0, (m, v) => v > m ? v : m);
    final todayIndex = now.weekday - 1;

    // Luôn hiện chart (giống design) — chưa có data thì cột là stub mờ + caption.
    final hasData = maxMinutes > 0;

    return ThemedCard(
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final pct = hasData ? minutesPerDay[i] / maxMinutes : 0.0;
                final isToday = i == todayIndex;
                final barColor = isToday
                    ? t.accent
                    : (hasData ? t.primary : t.surfaceSunken);
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
                            color: barColor,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _dayLabels[i],
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isToday
                                ? FontWeight.w800
                                : FontWeight.w700,
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
          if (!hasData) ...[
            const SizedBox(height: 14),
            Text(
              'Chưa có hoạt động tuần này',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: t.ink2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Hoàn thành một bộ câu hỏi để bắt đầu!',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: t.inkMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
