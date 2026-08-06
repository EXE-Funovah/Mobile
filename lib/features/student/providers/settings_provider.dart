import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mọi setting lưu tại máy (không sync BE).
class SettingsState {
  final int dailyGoalMinutes;
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool analyticsEnabled;
  final bool dailyReminderEnabled;
  final bool pushNotificationsEnabled;
  final bool emailReminderEnabled;

  const SettingsState({
    this.dailyGoalMinutes = 25,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.analyticsEnabled = true,
    this.dailyReminderEnabled = false,
    this.pushNotificationsEnabled = false,
    this.emailReminderEnabled = false,
  });

  SettingsState copyWith({
    int? dailyGoalMinutes,
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? analyticsEnabled,
    bool? dailyReminderEnabled,
    bool? pushNotificationsEnabled,
    bool? emailReminderEnabled,
  }) => SettingsState(
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    dailyReminderEnabled:
        dailyReminderEnabled ?? this.dailyReminderEnabled,
    pushNotificationsEnabled:
        pushNotificationsEnabled ?? this.pushNotificationsEnabled,
    emailReminderEnabled:
        emailReminderEnabled ?? this.emailReminderEnabled,
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
  static const _kDailyReminder = 'settings_daily_reminder';
  static const _kPushNotifications = 'settings_push_notifications';
  static const _kEmailReminder = 'settings_email_reminder';

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    state = SettingsState(
      dailyGoalMinutes: sp.getInt(_kGoal) ?? 25,
      soundEnabled: sp.getBool(_kSound) ?? true,
      hapticEnabled: sp.getBool(_kHaptic) ?? true,
      analyticsEnabled: sp.getBool(_kAnalytics) ?? true,
      dailyReminderEnabled: sp.getBool(_kDailyReminder) ?? false,
      pushNotificationsEnabled: sp.getBool(_kPushNotifications) ?? false,
      emailReminderEnabled: sp.getBool(_kEmailReminder) ?? false,
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

  /// Release-safe local preference only.
  /// Future notification scheduling / push delivery can read from these keys.
  Future<void> setDailyReminder(bool on) async {
    state = state.copyWith(dailyReminderEnabled: on);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kDailyReminder, on);
  }

  /// Release-safe local preference only.
  Future<void> setPushNotifications(bool on) async {
    state = state.copyWith(pushNotificationsEnabled: on);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kPushNotifications, on);
  }

  /// Release-safe local preference only.
  Future<void> setEmailReminder(bool on) async {
    state = state.copyWith(emailReminderEnabled: on);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kEmailReminder, on);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsController, SettingsState>(
      (ref) => SettingsController(),
    );
