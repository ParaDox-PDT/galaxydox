import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/nasa_api_client.dart';
import '../models/apod_model.dart';

final apodRemoteDataSourceProvider = Provider<ApodRemoteDataSource>((ref) {
  return ApodRemoteDataSourceImpl(client: ref.watch(nasaApiClientProvider));
});

abstract interface class ApodRemoteDataSource {
  Future<ApodModel?> fetchApod({DateTime? date});
}

class ApodRemoteDataSourceImpl implements ApodRemoteDataSource {
  const ApodRemoteDataSourceImpl({required NasaApiClient client})
    : _client = client;

  final NasaApiClient _client;

  @override
  Future<ApodModel?> fetchApod({DateTime? date}) async {
    try {
      final response = await _client.getApod(date: date);
      final data = response.data;

      if (response.statusCode == 404 || data == null || data.isEmpty) {
        return null;
      }

      return ApodModel.fromJson(data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException catch (error) {
      throw AppException(
        type: AppExceptionType.serialization,
        message: 'Unable to parse APOD data from NASA.',
        cause: error,
      );
    } catch (error) {
      throw AppException(
        type: AppExceptionType.unknown,
        message: 'Unexpected error while loading APOD.',
        cause: error,
      );
    }
  }

  AppException _mapDioException(DioException error) {
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
        message: 'NASA APOD took too long to respond.',
        cause: error,
      );
    }

    return AppException(
      type: AppExceptionType.network,
      message: 'Unable to reach NASA APOD right now.',
      cause: error,
    );
  }
}
