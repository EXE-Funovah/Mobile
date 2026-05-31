import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/decorative_blob.dart';
import '../../shared/widgets/mascot_avatar.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
        child: Stack(
          children: [
            // Decorative blobs floating
            Positioned(
              top: -60,
              right: -40,
              child: DecorativeBlob(
                color: AppColors.brandLight,
                size: 280,
              ),
            ),
            Positioned(
              bottom: -80,
              left: -50,
              child: DecorativeBlob(
                color: AppColors.accentOrange,
                size: 240,
                duration: const Duration(seconds: 9),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MascotAvatar(
                    size: 140,
                    bgColor: Colors.white.withValues(alpha: 0.15),
                    showGlow: true,
                  )
                      .animate()
                      .scale(
                          duration: 700.ms,
                          curve: Curves.elasticOut,
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1, 1))
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 28),
                  const Text(
                    'Mascoteach',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .moveY(begin: 12, end: 0),
                  const SizedBox(height: 6),
                  Text(
                    'Học vui — Dạy hay',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 500.ms)
                      .moveY(begin: 8, end: 0),
                  const SizedBox(height: 48),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
