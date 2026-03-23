import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/neo_repository_impl.dart';
import '../../domain/entities/near_earth_object.dart';
import '../../domain/usecases/get_near_earth_objects.dart';

final getNearEarthObjectsUseCaseProvider = Provider<GetNearEarthObjectsUseCase>(
  (ref) {
    return GetNearEarthObjectsUseCase(ref.watch(neoRepositoryProvider));
  },
);

final neoControllerProvider =
    NotifierProvider.autoDispose<NeoController, NeoState>(NeoController.new);

class NeoController extends Notifier<NeoState> {
  late final GetNearEarthObjectsUseCase _getNearEarthObjectsUseCase;

  @override
  NeoState build() {
    _getNearEarthObjectsUseCase = ref.watch(getNearEarthObjectsUseCaseProvider);
    Future<void>.microtask(load);
    return NeoState.initial();
  }

  Future<void> load({DateTime? startDate, DateTime? endDate}) async {
    final effectiveStart = startDate ?? state.startDate;
    final effectiveEnd = endDate ?? state.endDate;

    state = state.copyWith(
      status: NeoStatus.loading,
      startDate: effectiveStart,
      endDate: effectiveEnd,
      clearError: true,
    );

    final result = await _getNearEarthObjectsUseCase(
      startDate: effectiveStart,
      endDate: effectiveEnd,
    );

    state = result.when(
      success: (objects) {
        if (objects.isEmpty) {
          return state.copyWith(status: NeoStatus.empty, objects: const []);
        }

        return state.copyWith(status: NeoStatus.success, objects: objects);
      },
      failure: (exception) {
        return state.copyWith(
          status: NeoStatus.error,
          error: exception,
          objects: const [],
        );
      },
    );
  }

  Future<void> refresh() => load();

  Future<void> setDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return load(startDate: startDate, endDate: endDate);
  }
}

enum NeoStatus { loading, success, empty, error }

class NeoState {
  const NeoState({
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.objects,
    this.error,
  });

  factory NeoState.initial() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return NeoState(
      status: NeoStatus.loading,
      startDate: today,
      endDate: today.add(const Duration(days: 6)),
      objects: const [],
    );
  }

  final NeoStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final List<NearEarthObject> objects;
  final AppException? error;

  bool get isLoading => status == NeoStatus.loading;
  bool get hasError => status == NeoStatus.error && error != null;
  bool get isEmpty => status == NeoStatus.empty;

  NeoState copyWith({
    NeoStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    List<NearEarthObject>? objects,
    AppException? error,
    bool clearError = false,
  }) {
    return NeoState(
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      objects: objects ?? this.objects,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
