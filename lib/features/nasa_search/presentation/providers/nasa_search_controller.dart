import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/nasa_search_repository_impl.dart';
import '../../domain/entities/nasa_media_item.dart';
import '../../domain/usecases/search_nasa_media.dart';

final searchNasaMediaUseCaseProvider = Provider<SearchNasaMediaUseCase>((ref) {
  return SearchNasaMediaUseCase(ref.watch(nasaSearchRepositoryProvider));
});

final nasaSearchControllerProvider =
    NotifierProvider.autoDispose<NasaSearchController, NasaSearchState>(
      NasaSearchController.new,
    );

class NasaSearchController extends Notifier<NasaSearchState> {
  late final SearchNasaMediaUseCase _searchNasaMediaUseCase;
  int _requestVersion = 0;
  String? _lastResolvedQuery;
  NasaSearchMediaFilter? _lastResolvedFilter;

  @override
  NasaSearchState build() {
    _searchNasaMediaUseCase = ref.watch(searchNasaMediaUseCaseProvider);
    ref.onDispose(() {
      _requestVersion++;
    });
    return NasaSearchState.initial();
  }

  Future<void> search({String? query, bool force = false}) async {
    if (!ref.mounted) {
      return;
    }

    final effectiveQuery = (query ?? state.query).trim();
    final requestVersion = ++_requestVersion;
    final activeFilter = state.mediaTypeFilter;

    final shouldSkipDuplicateRequest =
        !force &&
        effectiveQuery.isNotEmpty &&
        _lastResolvedQuery == effectiveQuery &&
        _lastResolvedFilter == activeFilter &&
        (state.status == NasaSearchStatus.success ||
            state.status == NasaSearchStatus.empty);

    if (shouldSkipDuplicateRequest) {
      return;
    }

    state = state.copyWith(
      query: effectiveQuery,
      status: effectiveQuery.isEmpty
          ? NasaSearchStatus.idle
          : NasaSearchStatus.loading,
      clearError: true,
      clearResults: true,
    );

    if (effectiveQuery.isEmpty) {
      _lastResolvedQuery = null;
      _lastResolvedFilter = null;
      return;
    }

    final result = await _searchNasaMediaUseCase(
      query: effectiveQuery,
      mediaType: activeFilter.apiValue,
    );

    if (!ref.mounted || requestVersion != _requestVersion) {
      return;
    }

    state = result.when(
      success: (results) {
        _lastResolvedQuery = effectiveQuery;
        _lastResolvedFilter = activeFilter;
        if (results.isEmpty) {
          return state.copyWith(
            status: NasaSearchStatus.empty,
            results: const [],
          );
        }

        return state.copyWith(
          status: NasaSearchStatus.success,
          results: results,
        );
      },
      failure: (exception) {
        return state.copyWith(
          status: NasaSearchStatus.error,
          error: exception,
          results: const [],
        );
      },
    );
  }

  Future<void> setMediaTypeFilter(NasaSearchMediaFilter mediaTypeFilter) async {
    if (mediaTypeFilter == state.mediaTypeFilter) {
      return;
    }

    state = state.copyWith(mediaTypeFilter: mediaTypeFilter);

    if (state.query.isNotEmpty) {
      await search();
    }
  }

  Future<void> retry() async {
    if (state.query.isEmpty) {
      return;
    }

    await search(force: true);
  }
}

enum NasaSearchStatus { idle, loading, success, empty, error }

enum NasaSearchMediaFilter {
  image('image', 'Images'),
  video('video', 'Videos');

  const NasaSearchMediaFilter(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class NasaSearchState {
  const NasaSearchState({
    required this.status,
    required this.query,
    required this.results,
    required this.mediaTypeFilter,
    this.error,
  });

  factory NasaSearchState.initial() {
    return const NasaSearchState(
      status: NasaSearchStatus.idle,
      query: '',
      results: [],
      mediaTypeFilter: NasaSearchMediaFilter.image,
    );
  }

  final NasaSearchStatus status;
  final String query;
  final List<NasaMediaItem> results;
  final NasaSearchMediaFilter mediaTypeFilter;
  final AppException? error;

  bool get isIdle => status == NasaSearchStatus.idle;
  bool get isLoading => status == NasaSearchStatus.loading;
  bool get hasError => status == NasaSearchStatus.error && error != null;
  bool get isEmpty => status == NasaSearchStatus.empty;

  NasaSearchState copyWith({
    NasaSearchStatus? status,
    String? query,
    List<NasaMediaItem>? results,
    NasaSearchMediaFilter? mediaTypeFilter,
    AppException? error,
    bool clearError = false,
    bool clearResults = false,
  }) {
    return NasaSearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: clearResults ? const [] : (results ?? this.results),
      mediaTypeFilter: mediaTypeFilter ?? this.mediaTypeFilter,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
