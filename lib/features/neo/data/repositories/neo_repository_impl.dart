import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/near_earth_object.dart';
import '../../domain/repositories/neo_repository.dart';
import '../datasources/neo_remote_data_source.dart';

final neoRepositoryProvider = Provider<NeoRepository>((ref) {
  return NeoRepositoryImpl(
    remoteDataSource: ref.watch(neoRemoteDataSourceProvider),
  );
});

class NeoRepositoryImpl implements NeoRepository {
  const NeoRepositoryImpl({required NeoRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final NeoRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<NearEarthObject>>> getNearEarthObjects({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final models = await _remoteDataSource.fetchNearEarthObjects(
        startDate: startDate,
        endDate: endDate,
      );
      return Success(models.map((model) => model.toEntity()).toList());
    } on AppException catch (error) {
      return Failure(error);
    } catch (error) {
      return Failure(
        AppException(
          type: AppExceptionType.unknown,
          message: 'Unexpected error while building the NEO feed.',
          cause: error,
        ),
      );
    }
  }
}
