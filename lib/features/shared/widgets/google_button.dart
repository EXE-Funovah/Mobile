import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Nút "Tiếp tục với Google" — style giống `.auth-btn--google` trên web.
/// Vẽ logo Google bằng vector, không cần asset.
class GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final double height;

  const GoogleButton({
    super.key,
    required this.onPressed,
    this.label = 'Tiếp tục với Google',
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _GoogleLogo(size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Logo Google "G" 4 màu — vẽ bằng CustomPaint cho khỏi cần asset.
class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = w / 2;
    final innerR = r * 0.42;

    Paint p(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.fill;

    // Blue (top right)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.35,
      1.55,
      true,
      p(const Color(0xFF4285F4)),
    );
    // Green (bottom right)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      1.2,
      1.2,
      true,
      p(const Color(0xFF34A853)),
    );
    // Yellow (bottom left)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      2.4,
      1.4,
      true,
      p(const Color(0xFFFBBC04)),
    );
    // Red (top left)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.8,
      1.85,
      true,
      p(const Color(0xFFEA4335)),
    );

    // White inner hole
    canvas.drawCircle(Offset(cx, cy), innerR, p(Colors.white));

    // Horizontal bar making the "G" notch
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - h * 0.08, w * 0.45, h * 0.16),
      p(const Color(0xFF4285F4)),
    );
    canvas.drawRect(
      Rect.fromLTWH(cx + w * 0.18, cy - h * 0.08, w * 0.05, h * 0.16),
      p(Colors.white),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
