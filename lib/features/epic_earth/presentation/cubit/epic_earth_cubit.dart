import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../data/repositories/epic_earth_repository_impl.dart';
import '../../domain/entities/epic_image.dart';
import '../../domain/usecases/get_available_epic_dates.dart';
import '../../domain/usecases/get_epic_images_by_date.dart';
import '../../domain/usecases/get_latest_epic_images.dart';
import 'epic_earth_state.dart';

final getLatestEpicImagesUseCaseProvider = Provider<GetLatestEpicImagesUseCase>(
  (ref) {
    return GetLatestEpicImagesUseCase(ref.watch(epicEarthRepositoryProvider));
  },
);

final getAvailableEpicDatesUseCaseProvider =
    Provider<GetAvailableEpicDatesUseCase>((ref) {
      return GetAvailableEpicDatesUseCase(
        ref.watch(epicEarthRepositoryProvider),
      );
    });

final getEpicImagesByDateUseCaseProvider = Provider<GetEpicImagesByDateUseCase>(
  (ref) {
    return GetEpicImagesByDateUseCase(ref.watch(epicEarthRepositoryProvider));
  },
);

class EpicEarthCubit extends Cubit<EpicEarthState> {
  EpicEarthCubit({
    required GetLatestEpicImagesUseCase getLatestEpicImagesUseCase,
    required GetAvailableEpicDatesUseCase getAvailableEpicDatesUseCase,
    required GetEpicImagesByDateUseCase getEpicImagesByDateUseCase,
  }) : _getLatestEpicImagesUseCase = getLatestEpicImagesUseCase,
       _getAvailableEpicDatesUseCase = getAvailableEpicDatesUseCase,
       _getEpicImagesByDateUseCase = getEpicImagesByDateUseCase,
       super(EpicEarthState.initial());

  final GetLatestEpicImagesUseCase _getLatestEpicImagesUseCase;
  final GetAvailableEpicDatesUseCase _getAvailableEpicDatesUseCase;
  final GetEpicImagesByDateUseCase _getEpicImagesByDateUseCase;

  Future<void> loadLatest() async {
    await _loadLatest(showLoading: true);
  }

  Future<void> refresh() async {
    final selectedDate = state.selectedDate;
    if (selectedDate == null) {
      await _loadLatest(showLoading: false);
      return;
    }

    await _loadImagesByDate(selectedDate, showLoading: false);
  }

  Future<void> selectDate(DateTime date) async {
    await _loadImagesByDate(_normalizeDate(date), showLoading: true);
  }

  Future<void> _loadLatest({required bool showLoading}) async {
    _emitLoading(showLoading: showLoading);

    final availableDates = await _loadAvailableDates();
    final result = await _getLatestEpicImagesUseCase();
    if (isClosed) {
      return;
    }

    _emitImagesResult(
      result,
      selectedDate: _selectedDateFromLatest(result, availableDates),
      availableDates: availableDates,
    );
  }

  Future<void> _loadImagesByDate(
    DateTime date, {
    required bool showLoading,
  }) async {
    _emitLoading(showLoading: showLoading, selectedDate: date);

    final availableDates = await _loadAvailableDates();
    final result = await _getEpicImagesByDateUseCase(date);
    if (isClosed) {
      return;
    }

    _emitImagesResult(
      result,
      selectedDate: date,
      availableDates: availableDates,
    );
  }

  Future<List<DateTime>> _loadAvailableDates() async {
    final result = await _getAvailableEpicDatesUseCase();
    if (isClosed) {
      return state.availableDates;
    }

    return result.when(
      success: (dates) => dates,
      failure: (_) => state.availableDates,
    );
  }

  void _emitLoading({required bool showLoading, DateTime? selectedDate}) {
    if (showLoading) {
      emit(
        state.copyWith(
          status: EpicEarthStatus.loading,
          selectedDate: selectedDate,
          isRefreshing: false,
          clearError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedDate: selectedDate,
        isRefreshing: true,
        clearError: true,
      ),
    );
  }

  void _emitImagesResult(
    Result<List<EpicImage>> result, {
    required DateTime? selectedDate,
    required List<DateTime> availableDates,
  }) {
    emit(
      result.when(
        success: (images) {
          final normalizedSelectedDate = selectedDate == null
              ? null
              : _normalizeDate(selectedDate);

          return state.copyWith(
            status: images.isEmpty
                ? EpicEarthStatus.empty
                : EpicEarthStatus.loaded,
            images: images,
            selectedDate: normalizedSelectedDate,
            availableDates: availableDates,
            isRefreshing: false,
            clearError: true,
          );
        },
        failure: (exception) {
          return state.copyWith(
            status: EpicEarthStatus.error,
            images: const [],
            availableDates: availableDates,
            error: exception,
            isRefreshing: false,
          );
        },
      ),
    );
  }

  DateTime? _selectedDateFromLatest(
    Result<List<EpicImage>> result,
    List<DateTime> availableDates,
  ) {
    return result.when(
      success: (images) {
        if (images.isNotEmpty) {
          return _normalizeDate(images.first.date);
        }

        if (availableDates.isNotEmpty) {
          return availableDates.first;
        }

        return state.selectedDate;
      },
      failure: (_) => state.selectedDate,
    );
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
