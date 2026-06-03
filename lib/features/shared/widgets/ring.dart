import 'dart:math';
import 'package:flutter/material.dart';

/// Progress ring (circular) — khớp với `Ring` từ screens.jsx.
class Ring extends StatelessWidget {
  final double pct; // 0..1
  final double size;
  final double stroke;
  final Color color;
  final Color track;
  final Widget? child;

  const Ring({
    super.key,
    required this.pct,
    this.size = 56,
    this.stroke = 6,
    required this.color,
    required this.track,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              pct: pct.clamp(0, 1),
              stroke: stroke,
              color: color,
              track: track,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  final double stroke;
  final Color color;
  final Color track;
  _RingPainter({
    required this.pct,
    required this.stroke,
    required this.color,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = (size.width - stroke) / 2;

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, r, trackPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -pi / 2,
      2 * pi * pct,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.pct != pct || old.color != color || old.track != track;
}
