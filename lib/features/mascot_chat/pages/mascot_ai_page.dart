import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/voice_mode_view.dart';
import '../widgets/chat_mode_view.dart';

/// Entry point cho tính năng Mascot AI.
/// Mặc định mở **Voice mode** (tính năng chính: trò chuyện thật).
/// Có toggle ở top-right để chuyển sang Chat text.
class MascotAiPage extends StatefulWidget {
  const MascotAiPage({super.key});

  @override
  State<MascotAiPage> createState() => _MascotAiPageState();
}

class _MascotAiPageState extends State<MascotAiPage> {
  bool _voiceMode = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _voiceMode ? AppColors.brandNavy : AppColors.surface,
      child: Column(
        children: [
          // Top bar tối giản với toggle Voice/Chat
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
            color: _voiceMode ? AppColors.brandNavy : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _voiceMode ? 'Trò chuyện với Mascot' : 'Chat với Mascot',
                    style: TextStyle(
                      color: _voiceMode ? Colors.white : AppColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _ModeToggle(
                  voiceMode: _voiceMode,
                  onChanged: (v) => setState(() => _voiceMode = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOut,
              child: _voiceMode
                  ? const VoiceModeView(key: ValueKey('voice'))
                  : const ChatModeView(key: ValueKey('chat')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool voiceMode;
  final ValueChanged<bool> onChanged;

  const _ModeToggle({required this.voiceMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = voiceMode;
    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : AppColors.surface;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(
            icon: Icons.graphic_eq,
            selected: voiceMode,
            onTap: () => onChanged(true),
            label: 'Voice',
            isDark: isDark,
          ),
          _segment(
            icon: Icons.chat_bubble_outline,
            selected: !voiceMode,
            onTap: () => onChanged(false),
            label: 'Chat',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _segment({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required String label,
    required bool isDark,
  }) {
    final activeColor = isDark ? Colors.white : AppColors.brandBlue;
    final inactiveColor = isDark ? Colors.white70 : AppColors.inkMuted;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? Colors.white : AppColors.brandBlue)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? (isDark ? AppColors.brandNavy : Colors.white)
                  : (selected ? activeColor : inactiveColor),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected
                    ? (isDark ? AppColors.brandNavy : Colors.white)
                    : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    ).animate(target: selected ? 1 : 0).scaleXY(
          duration: 180.ms,
          begin: 1,
          end: 1.03,
        );
  }
}
