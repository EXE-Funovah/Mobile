import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../shared/widgets/ring.dart';
import '../../shared/widgets/section_head.dart';
import '../../shared/widgets/themed_card.dart';

class StudentProgressTab extends ConsumerWidget {
  const StudentProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    final week = const [
      (d: 'T2', v: 0.6),
      (d: 'T3', v: 0.9),
      (d: 'T4', v: 0.4),
      (d: 'T5', v: 1.0),
      (d: 'T6', v: 0.75),
      (d: 'T7', v: 0.5),
      (d: 'CN', v: 0.3),
    ];
    final badges = const [
      (i: Icons.local_fire_department, t: 'Streak 7 ngày', on: true, tint: 1),
      (i: Icons.mic, t: 'Nói 1 giờ', on: true, tint: 0),
      (i: Icons.gps_fixed, t: '100 câu đúng', on: true, tint: 2),
      (i: Icons.star, t: 'Cấp 10', on: false, tint: 3),
      (i: Icons.emoji_events, t: 'Top lớp', on: false, tint: 0),
      (i: Icons.bolt, t: '2000 XP', on: false, tint: 1),
    ];

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

        // Level card
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
          child: Row(
            children: [
              Ring(
                pct: 0.62,
                size: 84,
                stroke: 8,
                color: Colors.white,
                track: Colors.white.withValues(alpha: 0.25),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '8',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    Text(
                      'CẤP',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Học giả tập sự',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'còn 760 XP lên cấp 9',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    _XpBadge(),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SectionHead(title: 'Tuần này'),
        ThemedCard(
          child: SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: week.map((w) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: w.v * 80 + 6,
                          width: 22,
                          decoration: BoxDecoration(
                            color: w.v == 1 ? t.accent : t.primary,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          // opacity for non-max
                        ),
                        const SizedBox(height: 7),
                        Text(
                          w.d,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: t.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SectionHead(title: 'Huy hiệu'),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 11,
          crossAxisSpacing: 11,
          childAspectRatio: 0.95,
          children: badges.map((b) {
            return Opacity(
              opacity: b.on ? 1 : 0.5,
              child: ThemedCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: b.on ? t.tints[b.tint] : t.surfaceSunken,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        b.on ? b.i : Icons.lock,
                        color: b.on ? t.tintInks[b.tint] : t.inkMuted,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      b.t,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: t.ink,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _XpBadge extends ConsumerWidget {
  const _XpBadge();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.bolt, color: Colors.white, size: 15),
          SizedBox(width: 4),
          Text(
            '1.240 XP',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
