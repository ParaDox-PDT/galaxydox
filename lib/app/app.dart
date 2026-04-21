import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/notifications/presentation/widgets/notification_bootstrapper.dart';
import 'router/app_router.dart';

class GalaxyDoxApp extends ConsumerWidget {
  const GalaxyDoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return NotificationBootstrapper(child: child);
      },
    );
  }
}
