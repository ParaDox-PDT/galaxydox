import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/apod_item.dart';
import '../../domain/repositories/apod_repository.dart';
import '../datasources/apod_local_data_source.dart';
import '../datasources/apod_remote_data_source.dart';
import '../models/apod_model.dart';

final apodRepositoryProvider = Provider<ApodRepository>((ref) {
  return ApodRepositoryImpl(
    localDataSource: ref.watch(apodLocalDataSourceProvider),
    remoteDataSource: ref.watch(apodRemoteDataSourceProvider),
  );
});

class ApodRepositoryImpl implements ApodRepository {
  const ApodRepositoryImpl({
    required ApodLocalDataSource localDataSource,
    required ApodRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  final ApodLocalDataSource _localDataSource;
  final ApodRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ApodItem?>> getApod({
    DateTime? date,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cached = await _cachedApod(() {
          return _localDataSource.getApod(requestedDate: date);
        });
        if (cached != null) {
          return Success(cached.toEntity());
        }
      }

      final model = await _remoteDataSource.fetchApod(date: date);
      if (model != null) {
        await _ignoreCacheErrors(() {
          return _localDataSource.cacheApod(model, requestedDate: date);
        });
      }

      return Success(model?.toEntity());
    } on AppException catch (error) {
      final cached = await _cachedApod(() {
        return _localDataSource.getApod(requestedDate: date);
      });
      if (cached != null) {
        return Success(cached.toEntity());
      }

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

  static Future<ApodModel?> _cachedApod(
    Future<ApodModel?> Function() read,
  ) async {
    try {
      return await read();
    } catch (_) {
      return null;
    }
  }

  static Future<void> _ignoreCacheErrors(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      return;
    }
  }
}
