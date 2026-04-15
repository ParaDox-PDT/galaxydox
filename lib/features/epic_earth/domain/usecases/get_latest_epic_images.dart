import '../../../../core/errors/result.dart';
import '../entities/epic_image.dart';
import '../repositories/epic_earth_repository.dart';

class GetLatestEpicImagesUseCase {
  const GetLatestEpicImagesUseCase(this._repository);

  final EpicEarthRepository _repository;

  Future<Result<List<EpicImage>>> call() {
    return _repository.getLatestNaturalImages();
  }
}
