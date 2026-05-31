import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/decorative_blob.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/mascot_avatar.dart';

class StudentShell extends ConsumerStatefulWidget {
  const StudentShell({super.key});

  @override
  ConsumerState<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends ConsumerState<StudentShell> {
  int _index = 0;

  final _pages = const [
    _HomeTab(),
    _JoinTab(),
    _MyGamesTab(),
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
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner_outlined),
              selectedIcon: Icon(Icons.qr_code_scanner_rounded),
              label: 'Tham gia',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'Lịch sử',
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
    final name = ref.watch(authProvider).displayName ?? 'bạn';
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header với mascot
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
                    'Sẵn sàng chinh phục bài học mới? 🚀',
                    style: TextStyle(color: AppColors.inkSecondary),
                  ),
                ],
              ),
            ),
            const MascotAvatar(size: 64),
          ],
        ).animate().fadeIn(duration: 400.ms).moveX(begin: -16, end: 0),
        const SizedBox(height: 24),

        // Hero card "Tham gia bài học"
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.hover,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: DecorativeBlob(
                  color: AppColors.brandLight,
                  size: 140,
                ),
              ),
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tham gia bài học',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Nhập mã PIN từ giáo viên\nđể vào lớp ngay',
                          style: TextStyle(
                              color: Colors.white70, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.rocket_launch,
                        color: Colors.white, size: 36),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: 24),

        // Quick stats
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.emoji_events,
                value: '0',
                label: 'Điểm tuần',
                color: AppColors.accentOrange,
                bg: AppColors.surfaceAmber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department,
                value: '0',
                label: 'Streak',
                color: AppColors.accentPink,
                bg: AppColors.surfacePink,
              ),
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
            'Bài học gần đây',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientSky,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.menu_book,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quiz mẫu ${i + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 2),
                          const Text(
                            '10 câu • Demo',
                            style: TextStyle(
                                color: AppColors.inkMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.inkMuted),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (600 + i * 100).ms),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
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
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.inkSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _JoinTab extends StatelessWidget {
  const _JoinTab();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.gradientBrand,
                shape: BoxShape.circle,
                boxShadow: AppShadows.glow,
              ),
              child:
                  const Icon(Icons.qr_code_2, size: 56, color: Colors.white),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                duration: 2.seconds,
                begin: 0,
                end: -8,
                curve: Curves.easeInOut),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tham gia lớp học',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Nhập mã PIN giáo viên cung cấp',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.inkSecondary),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.card,
            ),
            child: const TextField(
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: 12,
                color: AppColors.brandBlue,
              ),
              decoration: InputDecoration(
                hintText: '------',
                hintStyle: TextStyle(
                    color: AppColors.inkLight,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
              maxLength: 6,
              buildCounter: _emptyCounter,
            ),
          ),
          const SizedBox(height: 16),
          GradientButton(
            label: 'Tham gia ngay',
            icon: Icons.arrow_forward_rounded,
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Quét mã QR'),
          ),
        ],
      ),
    );
  }

  static Widget? _emptyCounter(BuildContext context,
          {required int currentLength,
          required int? maxLength,
          required bool isFocused}) =>
      null;
}

class _MyGamesTab extends StatelessWidget {
  const _MyGamesTab();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history,
                size: 60, color: AppColors.brandBlue),
          ),
          const SizedBox(height: 16),
          const Text('Chưa có lịch sử',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text(
            'Tham gia bài học đầu tiên\nđể bắt đầu hành trình!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.inkSecondary, height: 1.5),
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
              gradient: AppColors.gradientPrimary,
              shape: BoxShape.circle,
              boxShadow: AppShadows.glow,
            ),
            child: const MascotAvatar(size: 110, bgColor: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          auth.displayName ?? 'Học sinh',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Học sinh',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.brandBlue, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 28),
        Card(
          child: Column(children: [
            _profileTile(Icons.settings_outlined, 'Cài đặt', () {}),
            const Divider(height: 1, indent: 56),
            _profileTile(Icons.notifications_outlined, 'Thông báo', () {}),
            const Divider(height: 1, indent: 56),
            _profileTile(Icons.help_outline, 'Trợ giúp', () {}),
            const Divider(height: 1, indent: 56),
            _profileTile(
              Icons.logout,
              'Đăng xuất',
              () => ref.read(authProvider.notifier).logout(),
              danger: true,
            ),
          ]),
        ),
      ],
    );
  }

  Widget _profileTile(IconData icon, String label, VoidCallback onTap,
      {bool danger = false}) {
    final color = danger ? AppColors.danger : AppColors.ink;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: danger
              ? AppColors.danger.withValues(alpha: 0.1)
              : AppColors.surfaceBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            color: danger ? AppColors.danger : AppColors.brandBlue, size: 20),
      ),
      title: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: danger
          ? null
          : const Icon(Icons.chevron_right, color: AppColors.inkMuted),
      onTap: onTap,
    );
  }
}
