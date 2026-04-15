import '../../../../core/errors/result.dart';
import '../entities/epic_image.dart';

abstract interface class EpicEarthRepository {
  Future<Result<List<EpicImage>>> getLatestNaturalImages();

  Future<Result<List<DateTime>>> getAvailableDates();

  Future<Result<List<EpicImage>>> getNaturalImagesByDate(DateTime date);
}
