import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap/configuration_required_app.dart';
import 'core/config/app_config.dart';
import 'shared/bookmarks/data/bookmark_hive_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BookmarkHiveBootstrap.initialize();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('FLUTTER ERROR: ${details.exceptionAsString()}');
      final stack = details.stack;
      if (stack != null) {
        debugPrintStack(stackTrace: stack);
      }
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('UNCAUGHT PLATFORM ERROR: $error');
      debugPrintStack(stackTrace: stack);
    }
    return true;
  };

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
