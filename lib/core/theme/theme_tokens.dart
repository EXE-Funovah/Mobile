import 'package:flutter/material.dart';

/// Hai biến thể theme từ design handoff: Clean (light) và GameShow (dark).
/// Cả hai dùng chung set component, chỉ khác token màu/radius/weight.
enum AppMode { clean, gameShow }

/// Tập token cho 1 theme — map sang CSS vars trong design.
class AppTokens {
  final AppMode mode;
  final bool isDark;

  // Surfaces
  final Color appBg;
  final Color surface;
  final Color surface2;
  final Color surfaceSunken;

  // Ink
  final Color ink;
  final Color ink2;
  final Color inkMuted;

  // Brand
  final Color primary;
  final Color primaryDeep;
  final Color primarySoft;
  final Color accent;
  final Color accentSoft;
  final Color line;
  final Color ok;
  final Color danger;

  // Hero
  final Gradient heroGradient;
  final Color heroInk;
  final Color statusbarInk;

  // Card
  final double cardRadius;
  final List<BoxShadow> cardShadow;
  final Border? cardBorder;

  // Nav
  final Color navBg;
  final Color navActive;
  final Color navIdle;

  // FAB
  final Gradient fabGradient;
  final Color fabRing;

  // Chip
  final Color chipBg;
  final Color chipInk;

  // Typography
  final FontWeight displayWeight;

  // Color rotation for tinted chips/icon-boxes (rotate by index 0..3)
  final List<Color> tints;
  final List<Color> tintInks;

  const AppTokens({
    required this.mode,
    required this.isDark,
    required this.appBg,
    required this.surface,
    required this.surface2,
    required this.surfaceSunken,
    required this.ink,
    required this.ink2,
    required this.inkMuted,
    required this.primary,
    required this.primaryDeep,
    required this.primarySoft,
    required this.accent,
    required this.accentSoft,
    required this.line,
    required this.ok,
    required this.danger,
    required this.heroGradient,
    required this.heroInk,
    required this.statusbarInk,
    required this.cardRadius,
    required this.cardShadow,
    required this.cardBorder,
    required this.navBg,
    required this.navActive,
    required this.navIdle,
    required this.fabGradient,
    required this.fabRing,
    required this.chipBg,
    required this.chipInk,
    required this.displayWeight,
    required this.tints,
    required this.tintInks,
  });

  /// Clean — sạch, nền sáng, bo 22, weight 700.
  static const clean = AppTokens(
    mode: AppMode.clean,
    isDark: false,
    appBg: Color(0xFFF6F8FB),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF1F5F9),
    surfaceSunken: Color(0xFFEEF3F8),
    ink: Color(0xFF0F1E33),
    ink2: Color(0xFF475569),
    inkMuted: Color(0xFF94A3B8),
    primary: Color(0xFF2B7AB5),
    primaryDeep: Color(0xFF1B3A6B),
    primarySoft: Color(0xFFE8F2FA),
    accent: Color(0xFFFB923C),
    accentSoft: Color(0xFFFFF1E6),
    line: Color(0xFFE6EDF4),
    ok: Color(0xFF16A34A),
    danger: Color(0xFFEF4444),
    heroGradient: LinearGradient(
      begin: Alignment(-0.7, -1),
      end: Alignment(0.7, 1),
      colors: [Color(0xFF2B7AB5), Color(0xFF1B3A6B)],
    ),
    heroInk: Color(0xFFFFFFFF),
    statusbarInk: Color(0xFF0F1E33),
    cardRadius: 22,
    cardShadow: [
      BoxShadow(color: Color(0x0F0F1E33), blurRadius: 20, offset: Offset(0, 4)),
      BoxShadow(color: Color(0x0A0F1E33), blurRadius: 2, offset: Offset(0, 1)),
    ],
    cardBorder: Border.fromBorderSide(BorderSide(color: Color(0xFFEDF2F7))),
    navBg: Color(0xEDFFFFFF),
    navActive: Color(0xFF2B7AB5),
    navIdle: Color(0xFF9DB0C4),
    fabGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF2B7AB5), Color(0xFF1B3A6B)],
    ),
    fabRing: Color(0x2E2B7AB5),
    chipBg: Color(0xFFEEF3F8),
    chipInk: Color(0xFF2B7AB5),
    displayWeight: FontWeight.w700,
    tints: [
      Color(0xFFE8F2FA),
      Color(0xFFFFF1E6),
      Color(0xFFEAF7EF),
      Color(0xFFF1ECFB),
    ],
    tintInks: [
      Color(0xFF2B7AB5),
      Color(0xFFEA7A22),
      Color(0xFF1A8A4F),
      Color(0xFF7A5AD9),
    ],
  );

  /// Game-show — nền tối kiểu Kahoot, accent cam.
  static const gameShow = AppTokens(
    mode: AppMode.gameShow,
    isDark: true,
    appBg: Color(0xFF14254A),
    surface: Color(0xFF1E3A66),
    surface2: Color(0xFF27406F),
    surfaceSunken: Color(0xFF16294F),
    ink: Color(0xFFFFFFFF),
    ink2: Color(0xFFB8C9E4),
    inkMuted: Color(0xFF7E94B8),
    primary: Color(0xFF5BAED4),
    primaryDeep: Color(0xFF3C8FC4),
    primarySoft: Color(0xFF23436F),
    accent: Color(0xFFFB923C),
    accentSoft: Color(0xFF3A2E22),
    line: Color(0xFF2C4472),
    ok: Color(0xFF34D399),
    danger: Color(0xFFEF4444),
    heroGradient: LinearGradient(
      begin: Alignment(-0.7, -1),
      end: Alignment(0.7, 1),
      colors: [Color(0xFF2B7AB5), Color(0xFF14254A)],
    ),
    heroInk: Color(0xFFFFFFFF),
    statusbarInk: Color(0xFFFFFFFF),
    cardRadius: 20,
    cardShadow: [
      BoxShadow(
        color: Color(0x52000000),
        blurRadius: 26,
        offset: Offset(0, 10),
      ),
    ],
    cardBorder: Border.fromBorderSide(BorderSide(color: Color(0x0FFFFFFF))),
    navBg: Color(0xF214254A),
    navActive: Color(0xFFFB923C),
    navIdle: Color(0xFF6E84A8),
    fabGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFB923C), Color(0xFFE8762B)],
    ),
    fabRing: Color(0x4DFB923C),
    chipBg: Color(0xFF23436F),
    chipInk: Color(0xFF9FD3EC),
    displayWeight: FontWeight.w800,
    tints: [
      Color(0xFF2B6FA8),
      Color(0xFFC8A333),
      Color(0xFF1E8A5A),
      Color(0xFF6A4BC0),
    ],
    tintInks: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
    ],
  );
}
