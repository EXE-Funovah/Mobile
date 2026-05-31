import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

/// Avatar mascot có animation float (lên xuống nhẹ nhàng).
/// Dùng ảnh `assets/images/mascot-head.png` đã tải từ frontend.
class MascotAvatar extends StatelessWidget {
  final double size;
  final bool bounce;
  final Color? bgColor;
  final bool showGlow;

  const MascotAvatar({
    super.key,
    this.size = 120,
    this.bounce = true,
    this.bgColor,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget mascot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: showGlow ? AppShadows.glow : null,
      ),
      padding: EdgeInsets.all(size * 0.1),
      child: Image.asset(
        'assets/images/mascot-head.png',
        fit: BoxFit.contain,
      ),
    );

    if (!bounce) return mascot;

    return mascot
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(
          duration: 2400.ms,
          begin: 0,
          end: -8,
          curve: Curves.easeInOut,
        );
  }
}
