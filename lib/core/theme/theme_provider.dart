import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_tokens.dart';

/// Provider chứa token hiện tại + có thể switch giữa Clean và GameShow.
class ThemeController extends StateNotifier<AppTokens> {
  // Default = Game-show (dark) theo design mockup. User có thể đổi trong Profile.
  ThemeController() : super(AppTokens.gameShow) {
    _load();
  }

  static const _prefKey = 'app_theme_mode';

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final saved = sp.getString(_prefKey);
    if (saved == 'clean') state = AppTokens.clean;
    // 'gameShow' hoặc null → giữ default gameShow
  }

  Future<void> toggle() async {
    state = state.mode == AppMode.clean ? AppTokens.gameShow : AppTokens.clean;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _prefKey,
      state.mode == AppMode.clean ? 'clean' : 'gameShow',
    );
  }

  Future<void> setMode(AppMode m) async {
    state = m == AppMode.clean ? AppTokens.clean : AppTokens.gameShow;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_prefKey, m == AppMode.clean ? 'clean' : 'gameShow');
  }
}

final themeProvider = StateNotifierProvider<ThemeController, AppTokens>(
  (_) => ThemeController(),
);

/// Build MaterialApp ThemeData từ tokens.
ThemeData buildThemeData(AppTokens t) {
  final base = t.isDark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  final textTheme = GoogleFonts.montserratTextTheme(
    base.textTheme,
  ).apply(bodyColor: t.ink, displayColor: t.ink);

  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: t.primary,
      brightness: t.isDark ? Brightness.dark : Brightness.light,
      primary: t.primary,
      secondary: t.accent,
      surface: t.surface,
    ),
    scaffoldBackgroundColor: t.appBg,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: t.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: t.ink,
      ),
      iconTheme: IconThemeData(color: t.ink),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: t.inkMuted),
      labelStyle: TextStyle(color: t.ink2, fontWeight: FontWeight.w500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: t.line, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: t.line, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: t.primary, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: t.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.cardRadius),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(color: t.line, thickness: 1, space: 1),
  );
}
