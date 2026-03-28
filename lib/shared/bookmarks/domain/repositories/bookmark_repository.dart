import '../../data/models/bookmark_item.dart';

abstract class BookmarkRepository {
  Future<List<BookmarkItem>> getBookmarks();

  Stream<List<BookmarkItem>> watchBookmarks();

  Future<void> saveBookmark(BookmarkItem item);

  Future<void> removeBookmark(String id);

  Future<bool> isBookmarked(String id);
}
