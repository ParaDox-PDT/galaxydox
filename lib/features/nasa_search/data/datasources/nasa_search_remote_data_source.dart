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

  Future<String?> resolveVideoPlaybackUrl({required String assetManifestUrl});
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
          .where(
            (item) =>
                item.previewUrl.isNotEmpty ||
                (item.assetManifestUrl?.isNotEmpty ?? false),
          )
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

  @override
  Future<String?> resolveVideoPlaybackUrl({
    required String assetManifestUrl,
  }) async {
    try {
      final response = await _client.searchMediaManifest(
        assetManifestUrl: assetManifestUrl,
      );
      final assets = response.data ?? const [];
      final candidates = assets.whereType<String>().toList();

      if (candidates.isEmpty) {
        return null;
      }

      return _selectPreferredVideoAsset(candidates);
    } on DioException catch (error) {
      throw _mapVideoManifestException(error);
    } on FormatException catch (error) {
      throw AppException(
        type: AppExceptionType.serialization,
        message: 'Unable to parse NASA video playback assets.',
        cause: error,
      );
    } catch (error) {
      throw AppException(
        type: AppExceptionType.unknown,
        message: 'Unexpected error while preparing NASA video playback.',
        cause: error,
      );
    }
  }

  AppException _mapDioException(DioException error) {
    return mapNasaDioException(
      error: error,
      resource: 'NASA media search',
      timeoutMessage: 'NASA media search took too long to respond.',
      networkMessage: 'Unable to reach NASA media search right now.',
    );
  }

  AppException _mapVideoManifestException(DioException error) {
    return mapNasaDioException(
      error: error,
      resource: 'NASA video assets',
      timeoutMessage: 'NASA video assets took too long to respond.',
      networkMessage: 'Unable to load NASA video playback right now.',
    );
  }

  String? _selectPreferredVideoAsset(List<String> assets) {
    const preferences = [
      '~medium.mp4',
      '~mobile.mp4',
      '~small.mp4',
      '~large.mp4',
      '~preview.mp4',
      '~orig.mp4',
      '.mp4',
      '.m4v',
      '.mov',
      '.webm',
      '.m3u8',
    ];

    for (final pattern in preferences) {
      for (final asset in assets) {
        if (_matchesPreferredVideoAsset(asset, pattern)) {
          return _normalizeHttpsUrl(asset);
        }
      }
    }

    return null;
  }

  bool _matchesPreferredVideoAsset(String asset, String pattern) {
    final normalized = asset.toLowerCase();
    return normalized.endsWith(pattern) &&
        !normalized.contains('.srt') &&
        !normalized.endsWith('.jpg') &&
        !normalized.endsWith('.json');
  }

  String _normalizeHttpsUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return value;
    }

    return uri.scheme.toLowerCase() == 'http'
        ? uri.replace(scheme: 'https').toString()
        : uri.toString();
  }
}
