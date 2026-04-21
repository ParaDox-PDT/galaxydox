import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notifications_firestore_data_source.dart';
import '../../data/datasources/notifications_local_data_source.dart';
import '../../domain/app_notification_entity.dart';

final notificationsProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsNotifier,
      List<AppNotificationEntity>
    >(NotificationsNotifier.new);

final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.maybeWhen(
    data: (items) => items.where((notification) => !notification.isRead).length,
    orElse: () => 0,
  );
});

class NotificationsNotifier extends AsyncNotifier<List<AppNotificationEntity>> {
  late final NotificationsLocalDataSource _local;
  late final NotificationsFirestoreDataSource _remote;

  @override
  Future<List<AppNotificationEntity>> build() async {
    _local = NotificationsLocalDataSource();
    _remote = ref.watch(notificationsFirestoreDataSourceProvider);

    final cached = await _local.getCached();
    if (cached != null && cached.isNotEmpty) {
      unawaited(Future<void>.microtask(syncSilently));
      return cached.map((item) => item.toEntity()).toList(growable: false);
    }

    return _fetchAndSave();
  }

  Future<void> syncSilently() async {
    try {
      final fresh = await _fetchAndSave();
      if (!ref.mounted) return;
      state = AsyncData(fresh);
    } catch (_) {
      // Keep showing existing cache if syncing fails.
    }
  }

  Future<void> forceRefresh() async {
    final current = state.asData?.value;
    if (current == null || current.isEmpty) {
      state = const AsyncLoading();
    }
    try {
      final fresh = await _fetchAndSave();
      if (!ref.mounted) return;
      state = AsyncData(fresh);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> markAsRead(String id) async {
    await _local.markAsRead(id);
    final current = state.asData?.value;
    if (!ref.mounted || current == null) return;

    state = AsyncData(
      current
          .map(
            (notification) => notification.id == id
                ? notification.copyWith(isRead: true)
                : notification,
          )
          .toList(growable: false),
    );
  }

  Future<void> markAllAsRead() async {
    await _local.markAllAsRead();
    final current = state.asData?.value;
    if (!ref.mounted || current == null) return;

    state = AsyncData(
      current
          .map((notification) => notification.copyWith(isRead: true))
          .toList(growable: false),
    );
  }

  Future<List<AppNotificationEntity>> _fetchAndSave() async {
    final models = await _remote.fetchNotifications();
    unawaited(_local.save(models));
    return models.map((item) => item.toEntity()).toList(growable: false);
  }
}
