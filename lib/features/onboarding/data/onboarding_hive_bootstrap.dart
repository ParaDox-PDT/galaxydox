import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'onboarding_local_data_source.dart';

abstract final class OnboardingHiveBootstrap {
  static Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(OnboardingLocalDataSource.boxName)) {
        await Hive.openBox(OnboardingLocalDataSource.boxName);
      }
    } catch (error, stackTrace) {
      debugPrint('ONBOARDING STORAGE INIT ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
