import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/nasa_api_client.dart';
import '../models/epic_image_model.dart';

final epicEarthRemoteDataSourceProvider = Provider<EpicEarthRemoteDataSource>((
  ref,
) {
  return EpicEarthRemoteDataSourceImpl(
    client: ref.watch(nasaApiClientProvider),
  );
});

abstract interface class EpicEarthRemoteDataSource {
  Future<List<EpicImageModel>> fetchLatestNaturalImages();

  Future<List<DateTime>> fetchAvailableDates();

  Future<List<EpicImageModel>> fetchNaturalImagesByDate(DateTime date);
}

class EpicEarthRemoteDataSourceImpl implements EpicEarthRemoteDataSource {
  const EpicEarthRemoteDataSourceImpl({required NasaApiClient client})
    : _client = client;

  final NasaApiClient _client;

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<List<EpicImageModel>> fetchLatestNaturalImages() async {
    try {
      final response = await _client.getLatestEpicNaturalImages();
      _validateResponse(response, 'latest EPIC natural images');
      return _parseImages(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error, 'latest EPIC natural images');
    } on FormatException catch (error) {
      throw AppException(
        type: AppExceptionType.serialization,
        message: 'Unable to parse EPIC image metadata from NASA.',
        cause: error,
      );
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }

      throw AppException(
        type: AppExceptionType.unknown,
        message: 'Unexpected error while loading EPIC Earth images.',
        cause: error,
      );
    }
  }

  @override
  Future<List<DateTime>> fetchAvailableDates() async {
    try {
      final response = await _client.getEpicNaturalAvailableDates();
      _validateResponse(response, 'EPIC available dates');
      final data = response.data;
      if (data == null) {
        throw const FormatException('EPIC available dates response was empty.');
      }

      final dates = data.map(_parseAvailableDate).toList(growable: false)
        ..sort((a, b) => b.compareTo(a));

      return dates;
    } on DioException catch (error) {
      throw _mapDioException(error, 'EPIC available dates');
    } on FormatException catch (error) {
      throw AppException(
        type: AppExceptionType.serialization,
        message: 'Unable to parse available EPIC dates from NASA.',
        cause: error,
      );
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }

      throw AppException(
        type: AppExceptionType.unknown,
        message: 'Unexpected error while loading EPIC available dates.',
        cause: error,
      );
    }
  }

  @override
  Future<List<EpicImageModel>> fetchNaturalImagesByDate(DateTime date) async {
    try {
      final response = await _client.getEpicNaturalImagesByDate(date: date);
      _validateResponse(
        response,
        'EPIC images for ${_dateFormat.format(date)}',
      );
      return _parseImages(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error, 'EPIC images for selected date');
    } on FormatException catch (error) {
      throw AppException(
        type: AppExceptionType.serialization,
        message: 'Unable to parse EPIC images for the selected date.',
        cause: error,
      );
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }

      throw AppException(
        type: AppExceptionType.unknown,
        message: 'Unexpected error while loading EPIC images by date.',
        cause: error,
      );
    }
  }

  static List<EpicImageModel> _parseImages(List<dynamic>? data) {
    if (data == null) {
      throw const FormatException('EPIC image response was empty.');
    }

    return data
        .map((item) {
          if (item is! Map) {
            throw const FormatException('EPIC image item was not an object.');
          }

          return EpicImageModel.fromJson(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
  }

  static DateTime _parseAvailableDate(Object? value) {
    final raw = value as String?;
    if (raw == null || raw.trim().isEmpty) {
      throw const FormatException('EPIC available date was empty.');
    }

    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) {
      throw FormatException('Invalid EPIC available date: $raw');
    }

    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static void _validateResponse(Response<dynamic> response, String resource) {
    final statusCode = response.statusCode;
    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      return;
    }

    if (statusCode == 401 || statusCode == 403) {
      throw AppException(
        type: AppExceptionType.unauthorized,
        message: 'NASA API key is invalid or unauthorized.',
        cause: response,
      );
    }

    throw AppException(
      type: AppExceptionType.network,
      message: 'NASA returned status $statusCode while loading $resource.',
      cause: response,
    );
  }

  static AppException _mapDioException(DioException error, String resource) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      return AppException(
        type: AppExceptionType.unauthorized,
        message: 'NASA API key is invalid or unauthorized.',
        cause: error,
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return AppException(
        type: AppExceptionType.timeout,
        message: 'NASA EPIC took too long to respond.',
        cause: error,
      );
    }

    return AppException(
      type: AppExceptionType.network,
      message: 'Unable to reach NASA EPIC while loading $resource.',
      cause: error,
    );
  }
}
