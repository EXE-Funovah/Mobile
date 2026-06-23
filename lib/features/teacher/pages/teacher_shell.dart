import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../mascot_chat/pages/mascot_ai_page.dart';
import '../../shared/widgets/decorative_blob.dart';
import '../../shared/widgets/mascot_avatar.dart';

class TeacherShell extends ConsumerStatefulWidget {
  const TeacherShell({super.key});

  @override
  ConsumerState<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends ConsumerState<TeacherShell> {
  int _index = 0;

  final _pages = const [
    _HomeTab(),
    _LibraryTab(),
    _SessionsTab(),
    MascotAiPage(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppShadows.soft,
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Thư viện',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event_rounded),
              label: 'Phiên',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'Mascot AI',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Tôi',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(authProvider).displayName ?? 'Thầy/Cô';
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Xin chào,',
                    style: TextStyle(color: AppColors.inkMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Hôm nay dạy gì cho học trò? 📚',
                    style: TextStyle(color: AppColors.inkSecondary),
                  ),
                ],
              ),
            ),
            const MascotAvatar(size: 64),
          ],
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 20),

        // CTA Mascot AI banner
        Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accentPink, AppColors.accentOrange],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.hover,
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -10,
                    child: DecorativeBlob(
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 140,
                    ),
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'MASCOT AI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Trợ lý dạy học của bạn',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tạo quiz, soạn bài, gợi ý hoạt động — chỉ cần hỏi.',
                              style: TextStyle(
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      MascotAvatar(
                        size: 70,
                        bgColor: Colors.white.withValues(alpha: 0.25),
                      ),
                    ],
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms)
            .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1)),
        const SizedBox(height: 24),

        // 4 stats grid
        GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: const [
                _StatCard(
                  icon: Icons.menu_book,
                  label: 'Quiz',
                  value: '0',
                  color: AppColors.brandBlue,
                  bg: AppColors.surfaceBlue,
                ),
                _StatCard(
                  icon: Icons.event,
                  label: 'Phiên live',
                  value: '0',
                  color: AppColors.accentOrange,
                  bg: AppColors.surfaceAmber,
                ),
                _StatCard(
                  icon: Icons.people,
                  label: 'Học sinh',
                  value: '0',
                  color: AppColors.accentEmerald,
                  bg: AppColors.surfaceTeal,
                ),
                _StatCard(
                  icon: Icons.auto_awesome,
                  label: 'Lượt chat AI',
                  value: '0',
                  color: AppColors.accentPink,
                  bg: AppColors.surfacePink,
                ),
              ],
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 500.ms)
            .moveY(begin: 12, end: 0),
        const SizedBox(height: 24),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Hành động nhanh',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _quickAction(
                Icons.upload_file,
                'Tạo quiz từ tài liệu',
                AppColors.brandBlue,
                () => context.push('/quiz/from-doc'),
                subtitle: 'AI đọc PDF/Word và soạn câu hỏi cho bạn',
                highlight: true,
              ),
              const Divider(height: 1, indent: 56),
              _quickAction(
                Icons.add_circle,
                'Tạo quiz thủ công',
                AppColors.brandMid,
                () {},
              ),
              const Divider(height: 1, indent: 56),
              _quickAction(
                Icons.play_circle,
                'Mở phiên live',
                AppColors.accentEmerald,
                () {},
              ),
              const Divider(height: 1, indent: 56),
              _quickAction(
                Icons.auto_awesome,
                'Trò chuyện với Mascot AI',
                AppColors.accentPink,
                () {},
              ),
            ],
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _quickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap, {
    String? subtitle,
    bool highlight = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: highlight
              ? LinearGradient(colors: [color, color.withValues(alpha: 0.7)])
              : null,
          color: highlight ? null : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: highlight ? Colors.white : color, size: 22),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          if (highlight) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accentPink.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'AI',
                style: TextStyle(
                  color: AppColors.accentPink,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: subtitle == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle,
                style: const TextStyle(color: AppColors.inkMuted, fontSize: 12),
              ),
            ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.inkMuted),
      onTap: onTap,
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.inkSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryTab extends StatelessWidget {
  const _LibraryTab();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thư viện quiz',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tất cả quiz của bạn',
            style: TextStyle(color: AppColors.inkSecondary),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Tìm quiz...',
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.inkMuted,
                  size: 22,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Expanded(
            child: Center(
              child: Text(
                'Chưa có quiz nào',
                style: TextStyle(color: AppColors.inkMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionsTab extends StatelessWidget {
  const _SessionsTab();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phiên live',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4),
          Text(
            'Quản lý các buổi học trực tiếp',
            style: TextStyle(color: AppColors.inkSecondary),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Chưa có phiên nào',
                style: TextStyle(color: AppColors.inkMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentOrange, AppColors.accentPink],
              ),
              shape: BoxShape.circle,
              boxShadow: AppShadows.glow,
            ),
            child: const MascotAvatar(size: 110, bgColor: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          auth.displayName ?? 'Giáo viên',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceAmber,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Giáo viên',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.accentOrange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Card(
          child: Column(
            children: [
              _tile(Icons.settings_outlined, 'Cài đặt', () {}),
              const Divider(height: 1, indent: 56),
              _tile(Icons.workspace_premium_outlined, 'Gói đăng ký', () {}),
              const Divider(height: 1, indent: 56),
              _tile(Icons.help_outline, 'Trợ giúp', () {}),
              const Divider(height: 1, indent: 56),
              _tile(
                Icons.logout,
                'Đăng xuất',
                () => ref.read(authProvider.notifier).logout(),
                danger: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool danger = false,
  }) {
    final color = danger ? AppColors.danger : AppColors.brandBlue;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: danger ? AppColors.danger : AppColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: danger
          ? null
          : const Icon(Icons.chevron_right, color: AppColors.inkMuted),
      onTap: onTap,
    );
  }
}
