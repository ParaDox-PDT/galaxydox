import '../../../../core/errors/result.dart';
import '../entities/mars_rover_photo.dart';
import '../repositories/mars_rover_repository.dart';

class GetMarsRoverPhotosUseCase {
  const GetMarsRoverPhotosUseCase(this._repository);

  final MarsRoverRepository _repository;

  Future<Result<List<MarsRoverPhoto>>> call({
    required MarsRoverName rover,
    DateTime? earthDate,
    int? sol,
  }) {
    return _repository.getPhotos(rover: rover, earthDate: earthDate, sol: sol);
  }
}
