import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'app/bootstrap/configuration_required_app.dart';
import 'core/config/app_config.dart';
import 'firebase_options.dart';
import 'features/onboarding/data/onboarding_hive_bootstrap.dart';
import 'shared/bookmarks/data/bookmark_hive_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await BookmarkHiveBootstrap.initialize();
  await OnboardingHiveBootstrap.initialize();

  if (!kIsWeb) {
    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      crashlytics.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(
    ProviderScope(
      child: AppConfig.requiresProductionConfiguration
          ? const ConfigurationRequiredApp()
          : const GalaxyDoxApp(),
    ),
  );
}

/// BUILD COMMANDS
/// flutter run --dart-define-from-file=.env
///
/// flutter build appbundle --release --dart-define-from-file=.env
///
/// flutter build apk --release --split-per-abi --dart-define-from-file=.env
///
/// WEB BUILD
/// flutter build web --release --dart-define-from-file=.env
//  dart tool/copy_web_redirects.dart
