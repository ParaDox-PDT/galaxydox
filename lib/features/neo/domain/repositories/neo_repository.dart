import '../../../../core/errors/result.dart';
import '../entities/near_earth_object.dart';

abstract interface class NeoRepository {
  Future<Result<List<NearEarthObject>>> getNearEarthObjects({
    DateTime? startDate,
    DateTime? endDate,
  });
}
