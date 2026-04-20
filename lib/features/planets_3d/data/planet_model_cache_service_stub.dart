import '../../../core/errors/app_exception.dart';
import 'models/resolved_planet_model.dart';

class PlanetModelCacheService {
  const PlanetModelCacheService();

  Future<ResolvedPlanetModel> prepareModel({
    required String planetId,
    required String modelUrl,
    void Function(double? progress)? onDownloadProgress,
  }) async {
    throw const AppException(
      type: AppExceptionType.unknown,
      message: '3D models are not supported on this platform.',
    );
  }
}
