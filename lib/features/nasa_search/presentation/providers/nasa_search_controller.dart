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

  @override
  NasaSearchState build() {
    _searchNasaMediaUseCase = ref.watch(searchNasaMediaUseCaseProvider);
    return NasaSearchState.initial();
  }

  Future<void> search({String? query}) async {
    final effectiveQuery = (query ?? state.query).trim();

    state = state.copyWith(
      query: effectiveQuery,
      status: effectiveQuery.isEmpty
          ? NasaSearchStatus.idle
          : NasaSearchStatus.loading,
      clearError: true,
      results: effectiveQuery.isEmpty ? const [] : null,
    );

    if (effectiveQuery.isEmpty) {
      return;
    }

    final result = await _searchNasaMediaUseCase(
      query: effectiveQuery,
      mediaType: state.mediaTypeFilter.apiValue,
    );

    state = result.when(
      success: (results) {
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

  void setViewMode(NasaSearchViewMode viewMode) {
    state = state.copyWith(viewMode: viewMode);
  }

  Future<void> setMediaTypeFilter(NasaSearchMediaFilter mediaTypeFilter) async {
    state = state.copyWith(mediaTypeFilter: mediaTypeFilter);
    await search();
  }

  Future<void> retry() => search();
}

enum NasaSearchStatus { idle, loading, success, empty, error }

enum NasaSearchViewMode { grid, list }

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
    required this.viewMode,
    required this.mediaTypeFilter,
    this.error,
  });

  factory NasaSearchState.initial() {
    return const NasaSearchState(
      status: NasaSearchStatus.idle,
      query: '',
      results: [],
      viewMode: NasaSearchViewMode.grid,
      mediaTypeFilter: NasaSearchMediaFilter.image,
    );
  }

  final NasaSearchStatus status;
  final String query;
  final List<NasaMediaItem> results;
  final NasaSearchViewMode viewMode;
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
    NasaSearchViewMode? viewMode,
    NasaSearchMediaFilter? mediaTypeFilter,
    AppException? error,
    bool clearError = false,
  }) {
    return NasaSearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      viewMode: viewMode ?? this.viewMode,
      mediaTypeFilter: mediaTypeFilter ?? this.mediaTypeFilter,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
