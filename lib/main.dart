import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exceptionAsString()}');

    final stack = details.stack;
    if (stack != null) {
      debugPrintStack(stackTrace: stack);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('UNCAUGHT PLATFORM ERROR: $error');
    debugPrintStack(stackTrace: stack);
    return true;
  };

  runApp(const ProviderScope(child: GalaxyDoxApp()));
}
