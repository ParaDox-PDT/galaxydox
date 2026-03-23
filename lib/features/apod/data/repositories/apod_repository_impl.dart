import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/apod_item.dart';
import '../../domain/repositories/apod_repository.dart';
import '../datasources/apod_remote_data_source.dart';

final apodRepositoryProvider = Provider<ApodRepository>((ref) {
  return ApodRepositoryImpl(
    remoteDataSource: ref.watch(apodRemoteDataSourceProvider),
  );
});

class ApodRepositoryImpl implements ApodRepository {
  const ApodRepositoryImpl({required ApodRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ApodRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ApodItem?>> getApod({DateTime? date}) async {
    try {
      final model = await _remoteDataSource.fetchApod(date: date);
      return Success(model?.toEntity());
    } on AppException catch (error) {
      return Failure(error);
    } catch (error) {
      return Failure(
        AppException(
          type: AppExceptionType.unknown,
          message: 'Unexpected error while building APOD content.',
          cause: error,
        ),
      );
    }
  }
}
