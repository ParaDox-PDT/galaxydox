import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap/configuration_required_app.dart';
import 'core/config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
