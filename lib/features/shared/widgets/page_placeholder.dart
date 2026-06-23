import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

/// Thumbnail trang sách — sọc 135° + vài dòng giả.
class PagePlaceholder extends ConsumerWidget {
  final double width;
  final double height;
  final int n;

  const PagePlaceholder({
    super.key,
    this.width = 96,
    this.height = 128,
    required this.n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeProvider);
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: t.cardShadow,
        border: t.cardBorder,
      ),
      child: Stack(
        children: [
          // sọc 135°
          Positioned.fill(
            child: CustomPaint(
              painter: _StripesPainter(color: t.surfaceSunken),
            ),
          ),
          // mấy dòng giả
          Positioned(
            left: 9,
            right: 9,
            top: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [1.0, 0.8, 0.9, 0.6, 0.85, 0.5].map((w) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: FractionallySizedBox(
                    widthFactor: w,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: t.inkMuted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // page number
          Positioned(
            bottom: 7,
            left: 9,
            child: Text(
              'Trang $n',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: t.inkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StripesPainter extends CustomPainter {
  final Color color;
  _StripesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 7;
    final step = 14.0;
    for (double i = -size.height; i < size.width + size.height; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
