import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/bookmark_item.dart';

final bookmarkLocalDataSourceProvider = Provider<BookmarkLocalDataSource>((
  ref,
) {
  final box = Hive.isBoxOpen(BookmarkLocalDataSource.boxName)
      ? Hive.box<BookmarkItem>(BookmarkLocalDataSource.boxName)
      : null;

  return BookmarkLocalDataSource(box);
});

class BookmarkLocalDataSource {
  const BookmarkLocalDataSource(this._box);

  static const boxName = 'bookmarks';

  final Box<BookmarkItem>? _box;

  Future<List<BookmarkItem>> getBookmarks() async {
    final box = _requireBox();
    return _sortBookmarks(box.values);
  }

  Stream<List<BookmarkItem>> watchBookmarks() {
    final box = _requireBox();

    return Stream<List<BookmarkItem>>.multi((controller) {
      controller.add(_sortBookmarks(box.values));

      final subscription = box.watch().listen(
        (_) => controller.add(_sortBookmarks(box.values)),
        onError: controller.addError,
      );

      controller.onCancel = subscription.cancel;
    });
  }

  Future<void> saveBookmark(BookmarkItem item) async {
    try {
      final box = _requireBox();
      await box.put(item.id, item);
    } catch (error) {
      throw _storageException(
        'Unable to save this bookmark on the device.',
        error,
      );
    }
  }

  Future<void> removeBookmark(String id) async {
    try {
      final box = _requireBox();
      await box.delete(id);
    } catch (error) {
      throw _storageException(
        'Unable to remove this bookmark from the device.',
        error,
      );
    }
  }

  Future<bool> isBookmarked(String id) async {
    final box = _requireBox();
    return box.containsKey(id);
  }

  Box<BookmarkItem> _requireBox() {
    final box = _box;
    if (box == null) {
      throw const AppException(
        type: AppExceptionType.storage,
        message: 'Local bookmark storage is not available right now.',
      );
    }
    return box;
  }

  List<BookmarkItem> _sortBookmarks(Iterable<BookmarkItem> values) {
    final items = values.toList(growable: false);
    items.sort((left, right) => right.savedAt.compareTo(left.savedAt));
    return items;
  }

  AppException _storageException(String message, Object cause) {
    return AppException(
      type: AppExceptionType.storage,
      message: message,
      cause: cause,
    );
  }
}
