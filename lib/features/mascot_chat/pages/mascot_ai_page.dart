import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../voice/pages/voice_chat_page.dart';
import '../widgets/chat_mode_view.dart';

/// Entry point cho tính năng Mascot AI.
/// Mặc định mở **Voice mode** (tính năng chính: trò chuyện thật — OpenAI Realtime).
/// Có toggle ở top-right để chuyển sang Chat text (cũng nối API thật).
///
/// [onBack]: khi mở dạng overlay (StudentShell) thì truyền để đóng Mascot.
/// Khi dùng làm tab (TeacherShell) thì để null — không hiện nút back.
class MascotAiPage extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const MascotAiPage({super.key, this.onBack});

  @override
  ConsumerState<MascotAiPage> createState() => _MascotAiPageState();
}

class _MascotAiPageState extends ConsumerState<MascotAiPage> {
  bool _voiceMode = true;

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(themeProvider);
    // Voice mode: nền navy (VoiceChatPage luôn dùng gradient tối).
    // Chat mode: theo theme người dùng (Clean/GameShow).
    final barColor = _voiceMode ? AppColors.brandNavy : t.surface;
    final fgColor = _voiceMode ? Colors.white : t.ink;

    return Scaffold(
      backgroundColor: _voiceMode ? AppColors.brandNavy : t.appBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar: [back?] tiêu đề + toggle Voice/Chat
            Container(
              padding: EdgeInsets.fromLTRB(
                widget.onBack != null ? 4 : 20,
                8,
                12,
                8,
              ),
              color: barColor,
              child: Row(
                children: [
                  if (widget.onBack != null)
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: fgColor,
                      ),
                      onPressed: widget.onBack,
                    ),
                  Expanded(
                    child: Text(
                      _voiceMode ? 'Trò chuyện với Mascot' : 'Chat với Mascot',
                      style: TextStyle(
                        color: fgColor,
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
                    ? VoiceChatPage(
                        key: const ValueKey('voice'),
                        embedded: true,
                        onBack: widget.onBack ?? () {},
                      )
                    : const ChatModeView(key: ValueKey('chat')),
              ),
            ),
          ],
        ),
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
        )
        .animate(target: selected ? 1 : 0)
        .scaleXY(duration: 180.ms, begin: 1, end: 1.03);
  }
}
