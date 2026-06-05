import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../quiz/providers/documents_provider.dart';
import '../../quiz/providers/quizzes_provider.dart';
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
                    icon: Icons.description_outlined,
                    value: '$docCount',
                    label: 'tài liệu',
                  ),
                  Container(
                    width: 1,
                    height: 38,
                    color: Colors.white.withValues(alpha: 0.25),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
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

        const SectionHead(title: 'Thống kê tuần này'),
        ThemedCard(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: Column(
            children: [
              Icon(Icons.insights, color: t.inkMuted, size: 36),
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
                'Theo dõi thời gian học hàng tuần',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: t.inkMuted,
                ),
              ),
            ],
          ),
        ),

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
