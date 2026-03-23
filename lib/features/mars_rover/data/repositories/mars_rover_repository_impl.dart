import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/mars_rover_photo.dart';
import '../../domain/repositories/mars_rover_repository.dart';
import '../datasources/mars_rover_remote_data_source.dart';

final marsRoverRepositoryProvider = Provider<MarsRoverRepository>((ref) {
  return MarsRoverRepositoryImpl(
    remoteDataSource: ref.watch(marsRoverRemoteDataSourceProvider),
  );
});

class MarsRoverRepositoryImpl implements MarsRoverRepository {
  const MarsRoverRepositoryImpl({
    required MarsRoverRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final MarsRoverRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<MarsRoverPhoto>>> getPhotos({
    required MarsRoverName rover,
    DateTime? earthDate,
    int? sol,
  }) async {
    try {
      final models = await _remoteDataSource.fetchPhotos(
        rover: rover,
        earthDate: earthDate,
        sol: sol,
      );

      return Success(models.map((model) => model.toEntity()).toList());
    } on AppException catch (error) {
      return Failure(error);
    } catch (error) {
      return Failure(
        AppException(
          type: AppExceptionType.unknown,
          message: 'Unexpected error while building rover gallery.',
          cause: error,
        ),
      );
    }
  }
}
