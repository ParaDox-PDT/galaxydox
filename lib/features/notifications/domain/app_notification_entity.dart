enum AppNotificationType {
  newWallpaper,
  unknown;

  static AppNotificationType fromRaw(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'new_wallpaper':
        return AppNotificationType.newWallpaper;
      default:
        return AppNotificationType.unknown;
    }
  }
}

extension AppNotificationTypeX on AppNotificationType {
  String get rawValue {
    switch (this) {
      case AppNotificationType.newWallpaper:
        return 'new_wallpaper';
      case AppNotificationType.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case AppNotificationType.newWallpaper:
        return 'New wallpaper';
      case AppNotificationType.unknown:
        return 'Update';
    }
  }

  bool get supportsDeepLink {
    switch (this) {
      case AppNotificationType.newWallpaper:
        return true;
      case AppNotificationType.unknown:
        return false;
    }
  }
}

class AppNotificationEntity {
  const AppNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.typeRaw,
    required this.routeId,
    required this.isRead,
    this.imageUrl,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String typeRaw;
  final String routeId;
  final bool isRead;
  final String? imageUrl;
  final DateTime? createdAt;

  AppNotificationType get type => AppNotificationType.fromRaw(typeRaw);
  bool get hasImage => (imageUrl?.trim().isNotEmpty ?? false);
  bool get isActionable => type.supportsDeepLink && routeId.trim().isNotEmpty;

  AppNotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? typeRaw,
    String? routeId,
    bool? isRead,
    String? imageUrl,
    DateTime? createdAt,
    bool clearImage = false,
  }) {
    return AppNotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      typeRaw: typeRaw ?? this.typeRaw,
      routeId: routeId ?? this.routeId,
      isRead: isRead ?? this.isRead,
      imageUrl: clearImage ? null : (imageUrl ?? this.imageUrl),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
