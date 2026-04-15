import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/epic_image.dart';

enum EpicEarthStatus { initial, loading, loaded, empty, error }

class EpicEarthState extends Equatable {
  const EpicEarthState({
    required this.status,
    required this.images,
    required this.availableDates,
    required this.isRefreshing,
    this.selectedDate,
    this.error,
  });

  factory EpicEarthState.initial() {
    return const EpicEarthState(
      status: EpicEarthStatus.initial,
      images: [],
      availableDates: [],
      isRefreshing: false,
    );
  }

  final EpicEarthStatus status;
  final List<EpicImage> images;
  final List<DateTime> availableDates;
  final DateTime? selectedDate;
  final AppException? error;
  final bool isRefreshing;

  bool get isLoading => status == EpicEarthStatus.loading;
  bool get hasError => status == EpicEarthStatus.error && error != null;
  bool get isEmpty => status == EpicEarthStatus.empty;
  bool get hasImages => images.isNotEmpty;

  EpicEarthState copyWith({
    EpicEarthStatus? status,
    List<EpicImage>? images,
    List<DateTime>? availableDates,
    DateTime? selectedDate,
    AppException? error,
    bool? isRefreshing,
    bool clearError = false,
  }) {
    return EpicEarthState(
      status: status ?? this.status,
      images: images ?? this.images,
      availableDates: availableDates ?? this.availableDates,
      selectedDate: selectedDate ?? this.selectedDate,
      error: clearError ? null : (error ?? this.error),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    images,
    availableDates,
    selectedDate,
    error,
    isRefreshing,
  ];
}
