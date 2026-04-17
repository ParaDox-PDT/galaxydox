import 'models/resolved_planet_model.dart';

class PlanetModelCacheService {
  const PlanetModelCacheService();

  Future<ResolvedPlanetModel> prepareModel({
    required String planetId,
    required String modelUrl,
    void Function(double? progress)? onDownloadProgress,
  }) async {
    onDownloadProgress?.call(1);
    return ResolvedPlanetModel(
      viewerSrc: modelUrl,
      isStoredLocally: false,
      wasLoadedFromCache: false,
    );
  }
}
