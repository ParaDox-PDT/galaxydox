import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'datasources/notifications_local_data_source.dart';

abstract final class NotificationHiveBootstrap {
  static Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(NotificationsLocalDataSource.boxName)) {
        await Hive.openBox<dynamic>(NotificationsLocalDataSource.boxName);
      }
    } catch (error, stackTrace) {
      debugPrint('NOTIFICATION STORAGE INIT ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
