import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pill mũi tên + % (xanh nếu tăng, đỏ nếu giảm).
class TrendPill extends StatelessWidget {
  final double percent;
  final bool up;
  final Color okColor;
  final Color downColor;
  const TrendPill({
    super.key,
    required this.percent,
    required this.up,
    required this.okColor,
    required this.downColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = up ? okColor : downColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.arrow_upward : Icons.arrow_downward,
            size: 11,
            color: c,
          ),
          const SizedBox(width: 2),
          Text(
            '${percent.abs().toStringAsFixed(1).replaceAll('.', ',')}%',
            style: TextStyle(
              color: c,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thanh ngang 1 dòng (icon chip + nhãn + giá trị + bar).
class HBar extends StatelessWidget {
  final String label;
  final String valueText;
  final double fraction; // 0..1
  final Color color;
  final Color trackColor;
  final Color labelColor;
  const HBar({
    super.key,
    required this.label,
    required this.valueText,
    required this.fraction,
    required this.color,
    required this.trackColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                ),
              ),
              Text(
                valueText,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.02, 1.0),
              minHeight: 7,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Area chart mini từ list số.
class MiniAreaChart extends StatelessWidget {
  final List<num> values;
  final Color color;
  final double height;
  const MiniAreaChart({
    super.key,
    required this.values,
    required this.color,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _AreaPainter(values, color)),
    );
  }
}

class _AreaPainter extends CustomPainter {
  final List<num> values;
  final Color color;
  _AreaPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce(math.max).toDouble();
    final minV = values.reduce(math.min).toDouble();
    final span = (maxV - minV).abs() < 1e-9 ? 1.0 : (maxV - minV);
    final dx = values.length > 1
        ? size.width / (values.length - 1)
        : size.width;

    Offset pt(int i) {
      final x = dx * i;
      final norm = (values[i].toDouble() - minV) / span;
      final y = size.height - norm * (size.height - 6) - 3;
      return Offset(x, y);
    }

    final line = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < values.length; i++) {
      line.lineTo(pt(i).dx, pt(i).dy);
    }
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _AreaPainter old) =>
      old.values != values || old.color != color;
}

/// Donut từ list (value, color).
class DonutChart extends StatelessWidget {
  final List<(num, Color)> segments;
  final String centerText;
  final String centerSub;
  final Color centerTextColor;
  final Color centerSubColor;
  final double size;
  const DonutChart({
    super.key,
    required this.segments,
    required this.centerText,
    required this.centerSub,
    required this.centerTextColor,
    required this.centerSubColor,
    this.size = 130,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size(size, size), painter: _DonutPainter(segments)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerText,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: centerTextColor,
                ),
              ),
              Text(
                centerSub,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: centerSubColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<(num, Color)> segments;
  _DonutPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (s, e) => s + e.$1.toDouble());
    if (total <= 0) return;
    final rect = Rect.fromLTWH(7, 7, size.width - 14, size.height - 14);
    var start = -math.pi / 2;
    final stroke = size.width * 0.16;
    for (final seg in segments) {
      final sweep = seg.$1.toDouble() / total * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep - 0.04,
        false,
        Paint()
          ..color = seg.$2
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.segments != segments;
}
