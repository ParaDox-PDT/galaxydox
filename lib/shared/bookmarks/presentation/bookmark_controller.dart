import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final bookmarkControllerProvider =
    AsyncNotifierProvider<BookmarkController, Set<String>>(
      BookmarkController.new,
    );

final isBookmarkedProvider = Provider.family<bool, String>((ref, bookmarkId) {
  final bookmarks = ref.watch(bookmarkControllerProvider);
  return bookmarks.maybeWhen(
    data: (ids) => ids.contains(bookmarkId),
    orElse: () => false,
  );
});

class BookmarkController extends AsyncNotifier<Set<String>> {
  static const _storageKey = 'galaxydox.bookmarks';

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_storageKey) ?? const []).toSet();
  }

  Future<void> toggle(String bookmarkId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = Set<String>.from(
      state.maybeWhen(data: (ids) => ids, orElse: () => const <String>{}),
    );

    if (!current.add(bookmarkId)) {
      current.remove(bookmarkId);
    }

    state = AsyncData(current);
    await prefs.setStringList(_storageKey, current.toList()..sort());
  }
}
