import '../../../../core/errors/result.dart';
import '../entities/mars_rover_photo.dart';

abstract interface class MarsRoverRepository {
  Future<Result<List<MarsRoverPhoto>>> getPhotos({
    required MarsRoverName rover,
    DateTime? earthDate,
    int? sol,
  });
}
