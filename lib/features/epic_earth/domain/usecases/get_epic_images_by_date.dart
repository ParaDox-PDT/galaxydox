import '../../../../core/errors/result.dart';
import '../entities/epic_image.dart';
import '../repositories/epic_earth_repository.dart';

class GetEpicImagesByDateUseCase {
  const GetEpicImagesByDateUseCase(this._repository);

  final EpicEarthRepository _repository;

  Future<Result<List<EpicImage>>> call(DateTime date) {
    return _repository.getNaturalImagesByDate(date);
  }
}
