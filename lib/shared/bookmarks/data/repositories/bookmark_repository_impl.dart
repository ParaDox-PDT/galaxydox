import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_local_data_source.dart';
import '../models/bookmark_item.dart';

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepositoryImpl(
    localDataSource: ref.watch(bookmarkLocalDataSourceProvider),
  );
});

class BookmarkRepositoryImpl implements BookmarkRepository {
  const BookmarkRepositoryImpl({
    required BookmarkLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final BookmarkLocalDataSource _localDataSource;

  @override
  Future<List<BookmarkItem>> getBookmarks() {
    return _localDataSource.getBookmarks();
  }

  @override
  Future<bool> isBookmarked(String id) {
    return _localDataSource.isBookmarked(id);
  }

  @override
  Future<void> removeBookmark(String id) {
    return _localDataSource.removeBookmark(id);
  }

  @override
  Future<void> saveBookmark(BookmarkItem item) {
    return _localDataSource.saveBookmark(item);
  }

  @override
  Stream<List<BookmarkItem>> watchBookmarks() {
    return _localDataSource.watchBookmarks();
  }
}
