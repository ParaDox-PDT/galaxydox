import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/app_notification_model.dart';

final notificationsFirestoreDataSourceProvider =
    Provider<NotificationsFirestoreDataSource>(
      (ref) => NotificationsFirestoreDataSourceImpl(FirebaseFirestore.instance),
    );

abstract interface class NotificationsFirestoreDataSource {
  Future<List<AppNotificationModel>> fetchNotifications();
}

class NotificationsFirestoreDataSourceImpl
    implements NotificationsFirestoreDataSource {
  NotificationsFirestoreDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications');

  @override
  Future<List<AppNotificationModel>> fetchNotifications() async {
    try {
      final snapshot = await _collection.get();
      final notifications =
          snapshot.docs
              .map(AppNotificationModel.fromDocument)
              .toList(growable: false)
            ..sort(_sortByCreatedAt);
      return notifications;
    } catch (error, stackTrace) {
      _throwMappedError(error, stackTrace);
    }
  }

  Never _throwMappedError(Object error, StackTrace stackTrace) {
    if (error is AppException) throw error;

    if (error is FirebaseException) {
      throw AppException(
        type: AppExceptionType.network,
        message: 'Notifications could not be loaded right now.',
        cause: error,
      );
    }

    throw AppException(
      type: AppExceptionType.unknown,
      message: 'An unexpected error occurred while loading notifications.',
      cause: error,
    );
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
