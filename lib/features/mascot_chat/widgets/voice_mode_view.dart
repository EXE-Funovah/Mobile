import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/mascot_avatar.dart';

/// Trạng thái cuộc trò chuyện voice với Mascot
enum VoiceState {
  idle, // chờ user bấm để bắt đầu
  listening, // đang nghe user nói
  thinking, // gửi lên server, chờ response
  speaking, // AI đang phát giọng nói
}

class VoiceModeView extends StatefulWidget {
  const VoiceModeView({super.key});

  @override
  State<VoiceModeView> createState() => _VoiceModeViewState();
}

class _VoiceModeViewState extends State<VoiceModeView> {
  VoiceState _state = VoiceState.idle;
  String? _userTranscript;
  String? _aiResponse;

  void _toggleListen() {
    if (_state == VoiceState.idle) {
      setState(() {
        _state = VoiceState.listening;
        _userTranscript = '';
        _aiResponse = null;
      });
      // TODO: thật sự gọi speech_to_text + WebSocket mascotChatService
      // Demo: giả lập nghe 2.5s → nghĩ 1s → trả lời 2s
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (!mounted) return;
        setState(() {
          _userTranscript = 'Tạo cho mình một quiz về phân số lớp 4';
          _state = VoiceState.thinking;
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() {
            _state = VoiceState.speaking;
            _aiResponse =
                'Được ngay! Mình đang soạn 5 câu hỏi về phân số cho lớp 4. Bạn có muốn mức độ Dễ, Vừa hay Khó?';
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (!mounted) return;
            setState(() => _state = VoiceState.idle);
          });
        });
      });
    } else {
      setState(() => _state = VoiceState.idle);
    }
  }

  String get _statusText {
    switch (_state) {
      case VoiceState.idle:
        return 'Bấm để bắt đầu trò chuyện';
      case VoiceState.listening:
        return 'Mascot đang nghe…';
      case VoiceState.thinking:
        return 'Mascot đang suy nghĩ…';
      case VoiceState.speaking:
        return 'Mascot đang trả lời';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.brandNavy,
            Color(0xFF0E2447),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Sao trang trí background
          ...List.generate(20, (i) => _Sparkle(seed: i)),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Mascot ở giữa với hiệu ứng theo state
                Expanded(
                  child: Center(
                    child: _MascotOrb(state: _state),
                  ),
                ),
                // Transcript
                _TranscriptPanel(
                  state: _state,
                  user: _userTranscript,
                  ai: _aiResponse,
                ),
                const SizedBox(height: 16),
                Text(
                  _statusText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                // Mic button + side controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SideButton(
                        icon: Icons.translate,
                        onTap: () {},
                        tooltip: 'Ngôn ngữ',
                      ),
                      _MicButton(state: _state, onTap: _toggleListen),
                      _SideButton(
                        icon: Icons.close,
                        onTap: () {
                          setState(() {
                            _state = VoiceState.idle;
                            _userTranscript = null;
                            _aiResponse = null;
                          });
                        },
                        tooltip: 'Kết thúc',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotOrb extends StatelessWidget {
  final VoiceState state;
  const _MascotOrb({required this.state});

  @override
  Widget build(BuildContext context) {
    final isActive = state != VoiceState.idle;
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vòng pulse ngoài cùng (chỉ khi active)
          if (isActive)
            _PulseRing(color: _ringColor(state), delay: 0.ms, size: 280),
          if (isActive)
            _PulseRing(color: _ringColor(state), delay: 600.ms, size: 280),
          if (isActive)
            _PulseRing(color: _ringColor(state), delay: 1200.ms, size: 280),

          // Glow orb
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _ringColor(state).withValues(alpha: 0.6),
                  _ringColor(state).withValues(alpha: 0.0),
                ],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                duration: 1800.ms,
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15),
                curve: Curves.easeInOut,
              ),

          // Mascot center
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _ringColor(state).withValues(alpha: 0.5),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const MascotAvatar(size: 160, bounce: true),
          ),
        ],
      ),
    );
  }

  Color _ringColor(VoiceState s) {
    switch (s) {
      case VoiceState.idle:
        return AppColors.brandMid;
      case VoiceState.listening:
        return AppColors.accentEmerald;
      case VoiceState.thinking:
        return AppColors.brandLight;
      case VoiceState.speaking:
        return AppColors.accentOrange;
    }
  }
}

class _PulseRing extends StatelessWidget {
  final Color color;
  final Duration delay;
  final double size;

  const _PulseRing({
    required this.color,
    required this.delay,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .scale(
          delay: delay,
          duration: 1800.ms,
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.1, 1.1),
          curve: Curves.easeOut,
        )
        .fadeOut(delay: delay + 600.ms, duration: 1200.ms);
  }
}

class _MicButton extends StatelessWidget {
  final VoiceState state;
  final VoidCallback onTap;

  const _MicButton({required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = state != VoiceState.idle;
    final color =
        active ? AppColors.accentEmerald : Colors.white;
    final iconColor = active ? Colors.white : AppColors.brandNavy;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(
          state == VoiceState.idle ? Icons.mic_rounded : Icons.stop_rounded,
          color: iconColor,
          size: 38,
        ),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _SideButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _TranscriptPanel extends StatelessWidget {
  final VoiceState state;
  final String? user;
  final String? ai;

  const _TranscriptPanel({required this.state, this.user, this.ai});

  @override
  Widget build(BuildContext context) {
    if (state == VoiceState.idle && (user == null || user!.isEmpty)) {
      return const SizedBox(height: 60);
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 60, maxHeight: 130),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null && user!.isNotEmpty) ...[
              Text(
                'BẠN',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
            ],
            if (ai != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'MASCOT',
                    style: TextStyle(
                      color: AppColors.accentOrange.withValues(alpha: 0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (state == VoiceState.speaking) ...[
                    const SizedBox(width: 6),
                    _SpeakingDots(),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                ai!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpeakingDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          margin: EdgeInsets.only(right: i < 2 ? 3 : 0),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.accentOrange,
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .scale(
              duration: 500.ms,
              delay: (i * 120).ms,
              begin: const Offset(1, 1),
              end: const Offset(1.8, 1.8),
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(1.8, 1.8),
              end: const Offset(1, 1),
              duration: 500.ms,
            );
      }),
    );
  }
}

class _Sparkle extends StatelessWidget {
  final int seed;
  const _Sparkle({required this.seed});

  @override
  Widget build(BuildContext context) {
    final r = Random(seed);
    final size = MediaQuery.of(context).size;
    return Positioned(
      left: r.nextDouble() * size.width,
      top: r.nextDouble() * size.height,
      child: Container(
        width: 2 + r.nextDouble() * 2,
        height: 2 + r.nextDouble() * 2,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3 + r.nextDouble() * 0.3),
          shape: BoxShape.circle,
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fadeOut(
            duration: (1500 + r.nextInt(2000)).ms,
            delay: (r.nextInt(2000)).ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}
