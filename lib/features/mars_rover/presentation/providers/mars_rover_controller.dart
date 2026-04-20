import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/mars_rover_repository_impl.dart';
import '../../domain/entities/mars_rover_photo.dart';
import '../../domain/usecases/get_mars_rover_photos.dart';

final getMarsRoverPhotosUseCaseProvider = Provider<GetMarsRoverPhotosUseCase>((
  ref,
) {
  return GetMarsRoverPhotosUseCase(ref.watch(marsRoverRepositoryProvider));
});

final marsRoverControllerProvider =
    NotifierProvider.autoDispose<MarsRoverController, MarsRoverState>(
      MarsRoverController.new,
    );

class MarsRoverController extends Notifier<MarsRoverState> {
  late final GetMarsRoverPhotosUseCase _getMarsRoverPhotosUseCase;
  int _requestVersion = 0;

  @override
  MarsRoverState build() {
    _getMarsRoverPhotosUseCase = ref.watch(getMarsRoverPhotosUseCaseProvider);
    ref.onDispose(() {
      _requestVersion++;
    });
    Future<void>.microtask(() async {
      if (!ref.mounted) {
        return;
      }

      await load();
    });
    return MarsRoverState.initial();
  }

  Future<void> load() async {
    if (!ref.mounted) {
      return;
    }

    final requestVersion = ++_requestVersion;
    state = state.copyWith(status: MarsRoverStatus.loading, clearError: true);

    final result = await _getMarsRoverPhotosUseCase(
      rover: state.selectedRover,
      earthDate: state.filterMode == MarsRoverFilterMode.earthDate
          ? state.earthDate
          : null,
      sol: state.filterMode == MarsRoverFilterMode.sol ? state.sol : null,
    );
    if (!ref.mounted || requestVersion != _requestVersion) {
      return;
    }

    state = result.when(
      success: (photos) {
        if (photos.isEmpty) {
          return state.copyWith(
            status: MarsRoverStatus.empty,
            photos: const [],
          );
        }

        return state.copyWith(status: MarsRoverStatus.success, photos: photos);
      },
      failure: (exception) {
        return state.copyWith(
          status: MarsRoverStatus.error,
          error: exception,
          photos: const [],
        );
      },
    );
  }

  Future<void> refresh() => load();

  Future<void> setRover(MarsRoverName rover) async {
    state = state.copyWith(selectedRover: rover);
    await load();
  }

  Future<void> setFilterMode(MarsRoverFilterMode mode) async {
    state = state.copyWith(filterMode: mode);
    await load();
  }

  Future<void> setEarthDate(DateTime date) async {
    state = state.copyWith(
      filterMode: MarsRoverFilterMode.earthDate,
      earthDate: date,
    );
    await load();
  }

  Future<void> setSol(int sol) async {
    state = state.copyWith(filterMode: MarsRoverFilterMode.sol, sol: sol);
    await load();
  }
}

enum MarsRoverStatus { loading, success, empty, error }

class MarsRoverState {
  const MarsRoverState({
    required this.status,
    required this.selectedRover,
    required this.filterMode,
    required this.earthDate,
    required this.sol,
    required this.photos,
    this.error,
  });

  factory MarsRoverState.initial() {
    return MarsRoverState(
      status: MarsRoverStatus.loading,
      selectedRover: MarsRoverName.curiosity,
      filterMode: MarsRoverFilterMode.sol,
      earthDate: DateTime(2015, 6, 3),
      sol: 1000,
      photos: const [],
    );
  }

  final MarsRoverStatus status;
  final MarsRoverName selectedRover;
  final MarsRoverFilterMode filterMode;
  final DateTime earthDate;
  final int sol;
  final List<MarsRoverPhoto> photos;
  final AppException? error;

  bool get isLoading => status == MarsRoverStatus.loading;
  bool get hasError => status == MarsRoverStatus.error && error != null;
  bool get isEmpty => status == MarsRoverStatus.empty;

  MarsRoverState copyWith({
    MarsRoverStatus? status,
    MarsRoverName? selectedRover,
    MarsRoverFilterMode? filterMode,
    DateTime? earthDate,
    int? sol,
    List<MarsRoverPhoto>? photos,
    AppException? error,
    bool clearError = false,
  }) {
    return MarsRoverState(
      status: status ?? this.status,
      selectedRover: selectedRover ?? this.selectedRover,
      filterMode: filterMode ?? this.filterMode,
      earthDate: earthDate ?? this.earthDate,
      sol: sol ?? this.sol,
      photos: photos ?? this.photos,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
