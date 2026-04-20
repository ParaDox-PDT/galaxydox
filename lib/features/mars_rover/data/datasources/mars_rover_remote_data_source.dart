import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/nasa_api_client.dart';
import '../../domain/entities/mars_rover_photo.dart';
import '../models/mars_rover_photo_model.dart';

final marsRoverRemoteDataSourceProvider = Provider<MarsRoverRemoteDataSource>((
  ref,
) {
  return MarsRoverRemoteDataSourceImpl(
    client: ref.watch(nasaApiClientProvider),
  );
});

abstract interface class MarsRoverRemoteDataSource {
  Future<List<MarsRoverPhotoModel>> fetchPhotos({
    required MarsRoverName rover,
    DateTime? earthDate,
    int? sol,
  });
}

class MarsRoverRemoteDataSourceImpl implements MarsRoverRemoteDataSource {
  const MarsRoverRemoteDataSourceImpl({required NasaApiClient client})
    : _client = client;

  final NasaApiClient _client;

  @override
  Future<List<MarsRoverPhotoModel>> fetchPhotos({
    required MarsRoverName rover,
    DateTime? earthDate,
    int? sol,
  }) async {
    try {
      final response = await _client.getMarsRoverPhotos(
        rover: rover.apiValue,
        earthDate: earthDate,
        sol: sol,
      );
      final data = response.data;
      final photos = (data?['photos'] as List<dynamic>? ?? const []);

      return photos
          .map(
            (item) =>
                MarsRoverPhotoModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException catch (error) {
      throw AppException(
        type: AppExceptionType.serialization,
        message: 'Unable to parse Mars rover data from NASA.',
        cause: error,
      );
    } catch (error) {
      throw AppException(
        type: AppExceptionType.unknown,
        message: 'Unexpected error while loading Mars rover photos.',
        cause: error,
      );
    }
  }

  AppException _mapDioException(DioException error) {
    return mapNasaDioException(
      error: error,
      resource: 'Mars rover photos',
      timeoutMessage: 'Mars rover photos took too long to respond.',
      networkMessage: 'Unable to reach NASA Mars rover photos right now.',
    );
  }
}
