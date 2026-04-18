import 'package:hive_flutter/hive_flutter.dart';

class OnboardingLocalDataSource {
  static const boxName = 'app_preferences';
  static const _keyCompleted = 'has_completed_onboarding';
  static const _keyRoute = 'preferred_launch_route';

  Box get _box => Hive.box(boxName);

  bool get hasCompletedOnboarding =>
      _box.get(_keyCompleted, defaultValue: false) as bool;

  String? get preferredLaunchRoute => _box.get(_keyRoute) as String?;

  Future<void> completeOnboarding({String? preferredRoute}) async {
    await _box.put(_keyCompleted, true);
    if (preferredRoute != null) {
      await _box.put(_keyRoute, preferredRoute);
    }
  }
}
