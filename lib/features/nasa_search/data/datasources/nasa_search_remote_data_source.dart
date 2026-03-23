import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/nasa_api_client.dart';
import '../models/nasa_media_item_model.dart';

final nasaSearchRemoteDataSourceProvider = Provider<NasaSearchRemoteDataSource>(
  (ref) {
    return NasaSearchRemoteDataSourceImpl(
      client: ref.watch(nasaApiClientProvider),
    );
  },
);

abstract interface class NasaSearchRemoteDataSource {
  Future<List<NasaMediaItemModel>> search({
    required String query,
    required String mediaType,
    int page = 1,
  });
}

class NasaSearchRemoteDataSourceImpl implements NasaSearchRemoteDataSource {
  const NasaSearchRemoteDataSourceImpl({required NasaApiClient client})
    : _client = client;

  final NasaApiClient _client;

  @override
  Future<List<NasaMediaItemModel>> search({
    required String query,
    required String mediaType,
    int page = 1,
  }) async {
    try {
      final response = await _client.searchMedia(
        query: query,
        mediaType: mediaType,
        page: page,
      );
      final data = response.data;
      final collection =
          data?['collection'] as Map<String, dynamic>? ?? const {};
      final items = collection['items'] as List<dynamic>? ?? const [];

      return items
          .map(
            (item) => NasaMediaItemModel.fromJson(item as Map<String, dynamic>),
          )
          .where((item) => item.previewUrl.isNotEmpty)
          .toList();
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException catch (error) {
      throw AppException(
        type: AppExceptionType.serialization,
        message: 'Unable to parse NASA media search results.',
        cause: error,
      );
    } catch (error) {
      throw AppException(
        type: AppExceptionType.unknown,
        message: 'Unexpected error while loading NASA media results.',
        cause: error,
      );
    }
  }

  AppException _mapDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return AppException(
        type: AppExceptionType.timeout,
        message: 'NASA media search took too long to respond.',
        cause: error,
      );
    }

    return AppException(
      type: AppExceptionType.network,
      message: 'Unable to reach NASA media search right now.',
      cause: error,
    );
  }
}
