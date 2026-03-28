import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'datasources/bookmark_local_data_source.dart';
import 'models/bookmark_item.dart';

abstract final class BookmarkHiveBootstrap {
  static Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(BookmarkContentTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(BookmarkItemAdapter());
      }

      if (!Hive.isBoxOpen(BookmarkLocalDataSource.boxName)) {
        await Hive.openBox<BookmarkItem>(BookmarkLocalDataSource.boxName);
      }
    } catch (error, stackTrace) {
      debugPrint('BOOKMARK STORAGE INIT ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
