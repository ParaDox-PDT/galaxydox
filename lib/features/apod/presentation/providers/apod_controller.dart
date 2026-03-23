import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/apod_repository_impl.dart';
import '../../domain/entities/apod_item.dart';
import '../../domain/usecases/get_apod.dart';

final getApodUseCaseProvider = Provider<GetApodUseCase>((ref) {
  return GetApodUseCase(ref.watch(apodRepositoryProvider));
});

final apodControllerProvider =
    NotifierProvider.autoDispose<ApodController, ApodState>(
      ApodController.new,
    );

class ApodController extends Notifier<ApodState> {
  late final GetApodUseCase _getApodUseCase;

  @override
  ApodState build() {
    _getApodUseCase = ref.watch(getApodUseCaseProvider);
    Future<void>.microtask(load);

    return const ApodState.loading();
  }

  Future<void> load({DateTime? forDate}) async {
    final effectiveDate = forDate ?? state.selectedDate;

    state = state.copyWith(
      status: ApodStatus.loading,
      selectedDate: effectiveDate,
      clearError: true,
    );

    final result = await _getApodUseCase(date: effectiveDate);

    state = result.when(
      success: (item) {
        if (item == null) {
          return state.copyWith(status: ApodStatus.empty, item: null);
        }

        return state.copyWith(status: ApodStatus.success, item: item);
      },
      failure: (exception) {
        return state.copyWith(
          status: ApodStatus.error,
          error: exception,
          item: null,
        );
      },
    );
  }

  Future<void> refresh() => load(forDate: state.selectedDate);

  Future<void> selectDate(DateTime? date) => load(forDate: date);
}

enum ApodStatus { loading, success, empty, error }

class ApodState {
  const ApodState({
    required this.status,
    this.item,
    this.error,
    this.selectedDate,
  });

  const ApodState.loading()
    : status = ApodStatus.loading,
      item = null,
      error = null,
      selectedDate = null;

  final ApodStatus status;
  final ApodItem? item;
  final AppException? error;
  final DateTime? selectedDate;

  bool get isLoading => status == ApodStatus.loading;
  bool get hasError => status == ApodStatus.error && error != null;
  bool get isEmpty => status == ApodStatus.empty;

  ApodState copyWith({
    ApodStatus? status,
    ApodItem? item,
    AppException? error,
    DateTime? selectedDate,
    bool clearError = false,
  }) {
    return ApodState(
      status: status ?? this.status,
      item: item ?? this.item,
      error: clearError ? null : (error ?? this.error),
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
