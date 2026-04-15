import '../../../../core/errors/result.dart';
import '../repositories/epic_earth_repository.dart';

class GetAvailableEpicDatesUseCase {
  const GetAvailableEpicDatesUseCase(this._repository);

  final EpicEarthRepository _repository;

  Future<Result<List<DateTime>>> call() {
    return _repository.getAvailableDates();
  }
}
