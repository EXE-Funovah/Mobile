import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mọi setting lưu tại máy (không sync BE).
class SettingsState {
  final int dailyGoalMinutes;
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool analyticsEnabled;

  const SettingsState({
    this.dailyGoalMinutes = 25,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.analyticsEnabled = true,
  });

  SettingsState copyWith({
    int? dailyGoalMinutes,
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? analyticsEnabled,
  }) => SettingsState(
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
  );
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState()) {
    _load();
  }

  static const _kGoal = 'settings_daily_goal';
  static const _kSound = 'settings_sound';
  static const _kHaptic = 'settings_haptic';
  static const _kAnalytics = 'settings_analytics';

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    state = SettingsState(
      dailyGoalMinutes: sp.getInt(_kGoal) ?? 25,
      soundEnabled: sp.getBool(_kSound) ?? true,
      hapticEnabled: sp.getBool(_kHaptic) ?? true,
      analyticsEnabled: sp.getBool(_kAnalytics) ?? true,
    );
  }

  Future<void> setDailyGoal(int minutes) async {
    state = state.copyWith(dailyGoalMinutes: minutes);
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kGoal, minutes);
  }

  Future<void> setSound(bool on) async {
    state = state.copyWith(soundEnabled: on);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kSound, on);
  }

  Future<void> setHaptic(bool on) async {
    state = state.copyWith(hapticEnabled: on);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kHaptic, on);
  }

  Future<void> setAnalytics(bool on) async {
    state = state.copyWith(analyticsEnabled: on);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kAnalytics, on);
  }
}

final settingsProvider = StateNotifierProvider<SettingsController, SettingsState>(
  (ref) => SettingsController(),
);
