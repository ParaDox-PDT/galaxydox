import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../domain/app_notification_entity.dart';

final notificationNavigationServiceProvider =
    Provider<NotificationNavigationService>(
      (ref) => const NotificationNavigationService(),
    );

class NotificationNavigationTarget {
  const NotificationNavigationTarget({
    required this.routeName,
    this.pathParameters = const <String, String>{},
  });

  final String routeName;
  final Map<String, String> pathParameters;
}

class NotificationNavigationPayload {
  const NotificationNavigationPayload({
    required this.typeRaw,
    required this.routeId,
  });

  final String? typeRaw;
  final String? routeId;
}

class NotificationNavigationService {
  const NotificationNavigationService();

  NotificationNavigationTarget resolveFromEntity(AppNotificationEntity entity) {
    return resolve(
      NotificationNavigationPayload(
        typeRaw: entity.typeRaw,
        routeId: entity.routeId,
      ),
    );
  }

  NotificationNavigationTarget resolve(NotificationNavigationPayload payload) {
    final type = AppNotificationType.fromRaw(payload.typeRaw);
    final routeId = payload.routeId?.trim() ?? '';

    switch (type) {
      case AppNotificationType.newWallpaper:
        if (routeId.isEmpty) {
          return const NotificationNavigationTarget(
            routeName: AppRoutes.wallpapersName,
          );
        }
        return NotificationNavigationTarget(
          routeName: AppRoutes.wallpaperDetailName,
          pathParameters: {'id': routeId},
        );
      case AppNotificationType.unknown:
        return const NotificationNavigationTarget(
          routeName: AppRoutes.notificationsName,
        );
    }
  }

  void pushFromEntity(GoRouter router, AppNotificationEntity entity) {
    final target = resolveFromEntity(entity);
    router.pushNamed(target.routeName, pathParameters: target.pathParameters);
  }

  void pushFromPayload(GoRouter router, NotificationNavigationPayload payload) {
    final target = resolve(payload);
    router.pushNamed(target.routeName, pathParameters: target.pathParameters);
  }
}
