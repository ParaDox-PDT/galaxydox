import 'package:hive_flutter/hive_flutter.dart';

class OnboardingLocalDataSource {
  static const boxName = 'app_preferences';
  static const _keyCompleted = 'has_completed_onboarding';
  static const _keyRoute = 'preferred_launch_route';
  static const _keyNotificationPrompted =
      'has_requested_notification_permission';
  static const _keyNotificationGranted = 'is_notification_permission_granted';

  Box get _box => Hive.box(boxName);

  bool get hasCompletedOnboarding =>
      _box.get(_keyCompleted, defaultValue: false) as bool;

  String? get preferredLaunchRoute => _box.get(_keyRoute) as String?;

  bool get hasRequestedNotificationPermission =>
      _box.get(_keyNotificationPrompted, defaultValue: false) as bool;

  bool get isNotificationPermissionGranted =>
      _box.get(_keyNotificationGranted, defaultValue: false) as bool;

  Future<void> completeOnboarding({String? preferredRoute}) async {
    await _box.put(_keyCompleted, true);
    if (preferredRoute != null) {
      await _box.put(_keyRoute, preferredRoute);
    }
  }

  Future<void> saveNotificationPermissionRequest({
    required bool granted,
  }) async {
    await _box.put(_keyNotificationPrompted, true);
    await _box.put(_keyNotificationGranted, granted);
  }

  Future<void> setNotificationPermissionGranted(bool granted) async {
    await _box.put(_keyNotificationGranted, granted);
  }
}
