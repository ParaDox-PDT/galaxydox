import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_notification_model.dart';

class NotificationsLocalDataSource {
  static const boxName = 'notifications_cache';
  static const _cacheKey = 'items';

  Future<Box<dynamic>> get _box async {
    if (Hive.isBoxOpen(boxName)) return Hive.box<dynamic>(boxName);
    return Hive.openBox<dynamic>(boxName);
  }

  Future<List<AppNotificationModel>?> getCached() async {
    try {
      final box = await _box;
      final raw = box.get(_cacheKey);
      if (raw == null) return null;
      final list = raw as List<dynamic>;
      if (list.isEmpty) return null;
      return list
          .map((item) => AppNotificationModel.fromMap(item as Map))
          .toList(growable: false)
        ..sort(_sortByCreatedAt);
    } catch (error) {
      debugPrint('NOTIFICATIONS CACHE READ ERROR: $error');
      return null;
    }
  }

  Future<List<AppNotificationModel>> save(
    List<AppNotificationModel> models,
  ) async {
    try {
      final box = await _box;
      final existing = await getCached() ?? const <AppNotificationModel>[];
      final existingById = {
        for (final notification in existing) notification.id: notification,
      };

      final merged = models.map((notification) {
        final previous = existingById[notification.id];
        return notification.copyWith(isRead: previous?.isRead ?? false);
      }).toList()..sort(_sortByCreatedAt);

      await box.put(
        _cacheKey,
        merged.map((notification) => notification.toMap()).toList(),
      );
      return merged;
    } catch (error) {
      debugPrint('NOTIFICATIONS CACHE WRITE ERROR: $error');
      return models..sort(_sortByCreatedAt);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final current = await getCached();
      if (current == null || current.isEmpty) return;

      final updated = current
          .map(
            (notification) => notification.id == id
                ? notification.copyWith(isRead: true)
                : notification,
          )
          .toList(growable: false);

      final box = await _box;
      await box.put(
        _cacheKey,
        updated.map((notification) => notification.toMap()).toList(),
      );
    } catch (error) {
      debugPrint('NOTIFICATIONS CACHE MARK READ ERROR: $error');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final current = await getCached();
      if (current == null || current.isEmpty) return;

      final updated = current
          .map((notification) => notification.copyWith(isRead: true))
          .toList(growable: false);

      final box = await _box;
      await box.put(
        _cacheKey,
        updated.map((notification) => notification.toMap()).toList(),
      );
    } catch (error) {
      debugPrint('NOTIFICATIONS CACHE MARK ALL READ ERROR: $error');
    }
  }

  static int _sortByCreatedAt(AppNotificationModel a, AppNotificationModel b) {
    final aTime = a.createdAt;
    final bTime = b.createdAt;
    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return 1;
    if (bTime == null) return -1;
    return bTime.compareTo(aTime);
  }
}
