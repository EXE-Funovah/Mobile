import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

enum NavTab { home, library, voice, progress, profile }

/// Bottom nav cao 72px với 4 slot label + slot trống ở giữa.
/// FAB voice được render riêng dưới dạng overlay (xem [StudentNavScaffold]).
class StudentBottomNav extends ConsumerWidget {
  final NavTab active;
  final ValueChanged<NavTab> onChange;

  const StudentBottomNav({
    super.key,
    required this.active,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: t.navBg,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavTab(
              label: 'Trang chủ',
              icon: Icons.home_outlined,
              iconActive: Icons.home_rounded,
              on: active == NavTab.home,
              onTap: () => onChange(NavTab.home),
              t: t,
            ),
          ),
          Expanded(
            child: _NavTab(
              label: 'Thư viện',
              icon: Icons.menu_book_outlined,
              iconActive: Icons.menu_book_rounded,
              on: active == NavTab.library,
              onTap: () => onChange(NavTab.library),
              t: t,
            ),
          ),
          // Slot trống cho FAB ở overlay
          const SizedBox(width: 76),
          Expanded(
            child: _NavTab(
              label: 'Tiến độ',
              icon: Icons.emoji_events_outlined,
              iconActive: Icons.emoji_events_rounded,
              on: active == NavTab.progress,
              onTap: () => onChange(NavTab.progress),
              t: t,
            ),
          ),
          Expanded(
            child: _NavTab(
              label: 'Hồ sơ',
              icon: Icons.person_outline,
              iconActive: Icons.person_rounded,
              on: active == NavTab.profile,
              onTap: () => onChange(NavTab.profile),
              t: t,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData iconActive;
  final bool on;
  final VoidCallback onTap;
  final dynamic t;

  const _NavTab({
    required this.label,
    required this.icon,
    required this.iconActive,
    required this.on,
    required this.onTap,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final color = on ? t.navActive : t.navIdle;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(on ? iconActive : icon, color: color, size: 23),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: on ? FontWeight.w700 : FontWeight.w600,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// FAB voice — overlay nổi giữa bottom nav.
class VoiceFab extends ConsumerWidget {
  final bool active;
  final VoidCallback onTap;
  const VoiceFab({super.key, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: t.fabGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: t.fabRing,
              blurRadius: 0,
              spreadRadius: active ? 7 : 0,
            ),
            const BoxShadow(
              color: Color(0x44000000),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
