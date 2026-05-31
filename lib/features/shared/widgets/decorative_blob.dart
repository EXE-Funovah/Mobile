import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Blob mờ trang trí background — float chậm tạo cảm giác sống động.
class DecorativeBlob extends StatelessWidget {
  final Color color;
  final double size;
  final Duration duration;

  const DecorativeBlob({
    super.key,
    required this.color,
    this.size = 200,
    this.duration = const Duration(seconds: 7),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.45), color.withValues(alpha: 0)],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.15, 1.15),
          duration: duration,
          curve: Curves.easeInOut,
        );
  }
}
