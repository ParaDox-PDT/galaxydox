import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/bookmark_item.dart';
import '../../data/repositories/bookmark_repository_impl.dart';
import '../../domain/repositories/bookmark_repository.dart';

final bookmarkControllerProvider =
    NotifierProvider<BookmarkController, BookmarkState>(BookmarkController.new);

final bookmarkIdsProvider = Provider<Set<String>>((ref) {
  return ref
      .watch(bookmarkControllerProvider)
      .items
      .map((bookmark) => bookmark.id)
      .toSet();
});

final isBookmarkedProvider = Provider.family<bool, String>((ref, bookmarkId) {
  return ref.watch(bookmarkIdsProvider).contains(bookmarkId);
});

class BookmarkController extends Notifier<BookmarkState> {
  late final BookmarkRepository _repository;
  StreamSubscription<List<BookmarkItem>>? _subscription;

  @override
  BookmarkState build() {
    _repository = ref.watch(bookmarkRepositoryProvider);
    ref.onDispose(() => _subscription?.cancel());
    Future<void>.microtask(_initialize);
    return const BookmarkState.loading();
  }

  Future<void> _initialize() async {
    try {
      final items = await _repository.getBookmarks();
      state = state.copyWith(
        status: BookmarkStatus.success,
        items: items,
        clearError: true,
      );

      await _subscription?.cancel();
      _subscription = _repository.watchBookmarks().listen(
        (items) {
          state = state.copyWith(
            status: BookmarkStatus.success,
            items: items,
            clearError: true,
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          state = state.copyWith(
            status: BookmarkStatus.error,
            error: _mapException(error),
          );
        },
      );
    } catch (error) {
      state = state.copyWith(
        status: BookmarkStatus.error,
        error: _mapException(error),
      );
    }
  }

  Future<BookmarkActionResult> toggle(BookmarkItem item) async {
    final isSaved = state.bookmarkIds.contains(item.id);
    return isSaved ? remove(item.id) : save(item);
  }

  Future<BookmarkActionResult> save(BookmarkItem item) async {
    final previous = state;
    final nextItems = _mergeBookmark(state.items, item);

    state = state.copyWith(
      status: BookmarkStatus.success,
      items: nextItems,
      clearError: true,
    );

    try {
      await _repository.saveBookmark(item);
      return const BookmarkActionResult.saved();
    } catch (error) {
      state = previous;
      return BookmarkActionResult.failure(_mapException(error).message);
    }
  }

  Future<BookmarkActionResult> remove(String id) async {
    final previous = state;
    final nextItems = state.items.where((item) => item.id != id).toList();

    state = state.copyWith(
      status: BookmarkStatus.success,
      items: nextItems,
      clearError: true,
    );

    try {
      await _repository.removeBookmark(id);
      return const BookmarkActionResult.removed();
    } catch (error) {
      state = previous;
      return BookmarkActionResult.failure(_mapException(error).message);
    }
  }

  Future<void> retry() => _initialize();

  List<BookmarkItem> _mergeBookmark(
    List<BookmarkItem> items,
    BookmarkItem bookmark,
  ) {
    final next = items.where((item) => item.id != bookmark.id).toList()
      ..insert(0, bookmark);
    return next;
  }

  AppException _mapException(Object error) {
    if (error is AppException) {
      return error;
    }

    return AppException(
      type: AppExceptionType.storage,
      message: 'Local bookmark storage is unavailable right now.',
      cause: error,
    );
  }
}

enum BookmarkStatus { loading, success, error }

class BookmarkState {
  const BookmarkState({required this.status, required this.items, this.error});

  const BookmarkState.loading()
    : status = BookmarkStatus.loading,
      items = const [],
      error = null;

  final BookmarkStatus status;
  final List<BookmarkItem> items;
  final AppException? error;

  bool get isLoading => status == BookmarkStatus.loading && items.isEmpty;
  bool get hasError => status == BookmarkStatus.error && error != null;
  bool get isEmpty => status == BookmarkStatus.success && items.isEmpty;
  Set<String> get bookmarkIds => items.map((item) => item.id).toSet();

  BookmarkState copyWith({
    BookmarkStatus? status,
    List<BookmarkItem>? items,
    AppException? error,
    bool clearError = false,
  }) {
    return BookmarkState(
      status: status ?? this.status,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BookmarkActionResult {
  const BookmarkActionResult._({
    required this.message,
    required this.didChange,
    this.isBookmarked,
  });

  const BookmarkActionResult.saved()
    : this._(
        message: 'Saved to bookmarks.',
        didChange: true,
        isBookmarked: true,
      );

  const BookmarkActionResult.removed()
    : this._(
        message: 'Removed from bookmarks.',
        didChange: true,
        isBookmarked: false,
      );

  const BookmarkActionResult.failure(String message)
    : this._(message: message, didChange: false);

  final String message;
  final bool didChange;
  final bool? isBookmarked;
}
