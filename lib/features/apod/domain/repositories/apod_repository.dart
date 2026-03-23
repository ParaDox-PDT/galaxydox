import '../../../../core/errors/result.dart';
import '../entities/apod_item.dart';

abstract interface class ApodRepository {
  Future<Result<ApodItem?>> getApod({DateTime? date});
}
