import '../../../../core/errors/result.dart';
import '../entities/nasa_media_item.dart';

abstract interface class NasaSearchRepository {
  Future<Result<List<NasaMediaItem>>> search({
    required String query,
    required String mediaType,
    int page = 1,
  });

  Future<Result<String?>> resolveVideoPlaybackUrl({
    required String assetManifestUrl,
  });
}
