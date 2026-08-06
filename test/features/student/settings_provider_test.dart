import 'package:flutter_test/flutter_test.dart';
import 'package:mascoteach_mobile/features/student/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('settings controller loads persisted reminder toggles', () async {
    SharedPreferences.setMockInitialValues({
      'settings_daily_reminder': true,
      'settings_push_notifications': true,
      'settings_email_reminder': false,
    });

    final controller = SettingsController();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(controller.state.dailyReminderEnabled, isTrue);
    expect(controller.state.pushNotificationsEnabled, isTrue);
    expect(controller.state.emailReminderEnabled, isFalse);
  });

  test('settings controller persists reminder toggles', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = SettingsController();

    await controller.setDailyReminder(true);
    await controller.setPushNotifications(true);
    await controller.setEmailReminder(true);

    final prefs = await SharedPreferences.getInstance();
    expect(controller.state.dailyReminderEnabled, isTrue);
    expect(controller.state.pushNotificationsEnabled, isTrue);
    expect(controller.state.emailReminderEnabled, isTrue);
    expect(prefs.getBool('settings_daily_reminder'), isTrue);
    expect(prefs.getBool('settings_push_notifications'), isTrue);
    expect(prefs.getBool('settings_email_reminder'), isTrue);
  });
}
