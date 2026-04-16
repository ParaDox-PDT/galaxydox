import '../../../../core/errors/result.dart';
import '../repositories/nasa_search_repository.dart';

class ResolveNasaVideoPlaybackUrlUseCase {
  const ResolveNasaVideoPlaybackUrlUseCase(this._repository);

  final NasaSearchRepository _repository;

  Future<Result<String?>> call({required String assetManifestUrl}) {
    return _repository.resolveVideoPlaybackUrl(
      assetManifestUrl: assetManifestUrl,
    );
  }
}
