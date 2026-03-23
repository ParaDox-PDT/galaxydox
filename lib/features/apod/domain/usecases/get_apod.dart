import '../../../../core/errors/result.dart';
import '../entities/apod_item.dart';
import '../repositories/apod_repository.dart';

class GetApodUseCase {
  const GetApodUseCase(this._repository);

  final ApodRepository _repository;

  Future<Result<ApodItem?>> call({DateTime? date}) {
    return _repository.getApod(date: date);
  }
}
