import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens copy từ tailwind.config.js của frontend Mascoteach
/// để mobile và web đồng nhất.
class AppColors {
  AppColors._();

  // Brand spectrum (navy → blue → mid → light)
  static const Color brandNavy = Color(0xFF1B3A6B);
  static const Color brandBlue = Color(0xFF2B7AB5);
  static const Color brandMid = Color(0xFF5BAED4);
  static const Color brandLight = Color(0xFFA8D8EA);

  // Accents
  static const Color accentOrange = Color(0xFFFB923C);
  static const Color accentEmerald = Color(0xFF34D399);
  static const Color accentPink = Color(0xFFEC4899);

  // Surfaces (pastel)
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceWhite = Colors.white;
  static const Color surfaceBlue = Color(0xFFF0F9FF);
  static const Color surfaceViolet = Color(0xFFF5F3FF);
  static const Color surfacePink = Color(0xFFFFF1F2);
  static const Color surfaceTeal = Color(0xFFF0FDFA);
  static const Color surfaceAmber = Color(0xFFFFFBEB);
  static const Color surfacePeach = Color(0xFFFFF5F0);
  static const Color surfaceLavender = Color(0xFFF0EEFF);

  // Ink (text)
  static const Color ink = Color(0xFF0F172A);
  static const Color inkSecondary = Color(0xFF334155);
  static const Color inkMuted = Color(0xFF94A3B8);
  static const Color inkLight = Color(0xFFCBD5E1);

  static const Color border = Color(0xFFE2E8F0);
  static const Color danger = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandNavy, brandBlue, brandMid],
  );

  static const LinearGradient gradientBrand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandBlue, brandMid],
  );

  static const LinearGradient gradientSky = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandLight, brandMid],
  );

  static const LinearGradient gradientSubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0F9FF), Color(0xFFE0F0FA), Color(0xFFF0F8FF)],
  );
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft = const [
    BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static List<BoxShadow> card = const [
    BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static List<BoxShadow> hover = const [
    BoxShadow(color: Color(0x1F1B3A6B), blurRadius: 48, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x141B3A6B), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> btn = const [
    BoxShadow(color: Color(0x662B7AB5), blurRadius: 14, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x332B7AB5), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static List<BoxShadow> glow = const [
    BoxShadow(color: Color(0x401B3A6B), blurRadius: 40),
    BoxShadow(color: Color(0x1A1B3A6B), blurRadius: 80),
  ];
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.montserratTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandBlue,
        brightness: Brightness.light,
        primary: AppColors.brandBlue,
        secondary: AppColors.brandMid,
        surface: AppColors.surfaceWhite,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FBFE),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.inkMuted),
        labelStyle: const TextStyle(
          color: AppColors.inkSecondary,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.brandMid, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandBlue,
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        indicatorColor: AppColors.brandBlue.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        height: 72,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
