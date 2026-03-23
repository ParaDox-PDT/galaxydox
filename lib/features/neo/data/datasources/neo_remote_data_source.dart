import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/nasa_api_client.dart';
import '../models/near_earth_object_model.dart';

final neoRemoteDataSourceProvider = Provider<NeoRemoteDataSource>((ref) {
  return NeoRemoteDataSourceImpl(client: ref.watch(nasaApiClientProvider));
});

abstract interface class NeoRemoteDataSource {
  Future<List<NearEarthObjectModel>> fetchNearEarthObjects({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class NeoRemoteDataSourceImpl implements NeoRemoteDataSource {
  const NeoRemoteDataSourceImpl({required NasaApiClient client})
    : _client = client;

  final NasaApiClient _client;

  @override
  Future<List<NearEarthObjectModel>> fetchNearEarthObjects({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _client.getNearEarthObjects(
        startDate: startDate,
        endDate: endDate,
      );
      final data = response.data;
      final objectsByDate =
          data?['near_earth_objects'] as Map<String, dynamic>? ?? const {};

      final items = <NearEarthObjectModel>[];
      for (final entry in objectsByDate.entries) {
        final objects = entry.value as List<dynamic>? ?? const [];
        for (final object in objects) {
          items.add(
            NearEarthObjectModel.fromJson(
              object as Map<String, dynamic>,
              fallbackDate: entry.key,
            ),
          );
        }
      }

      items.sort(
        (left, right) =>
            left.closeApproachDate.compareTo(right.closeApproachDate),
      );
      return items;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException catch (error) {
      throw AppException(
        type: AppExceptionType.serialization,
        message: 'Unable to parse NASA near-earth object data.',
        cause: error,
      );
    } catch (error) {
      throw AppException(
        type: AppExceptionType.unknown,
        message: 'Unexpected error while loading near-earth objects.',
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
        message: 'Near-earth object data took too long to respond.',
        cause: error,
      );
    }

    return AppException(
      type: AppExceptionType.network,
      message: 'Unable to reach NASA near-earth object data right now.',
      cause: error,
    );
  }
}
