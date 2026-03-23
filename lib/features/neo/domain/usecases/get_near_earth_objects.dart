import '../../../../core/errors/result.dart';
import '../entities/near_earth_object.dart';
import '../repositories/neo_repository.dart';

class GetNearEarthObjectsUseCase {
  const GetNearEarthObjectsUseCase(this._repository);

  final NeoRepository _repository;

  Future<Result<List<NearEarthObject>>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _repository.getNearEarthObjects(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
