import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/epic_image.dart';
import '../../domain/repositories/epic_earth_repository.dart';
import '../datasources/epic_earth_local_data_source.dart';
import '../datasources/epic_earth_remote_data_source.dart';
import '../models/epic_image_model.dart';

final epicEarthRepositoryProvider = Provider<EpicEarthRepository>((ref) {
  return EpicEarthRepositoryImpl(
    remoteDataSource: ref.watch(epicEarthRemoteDataSourceProvider),
    localDataSource: ref.watch(epicEarthLocalDataSourceProvider),
  );
});

class EpicEarthRepositoryImpl implements EpicEarthRepository {
  const EpicEarthRepositoryImpl({
    required EpicEarthRemoteDataSource remoteDataSource,
    required EpicEarthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final EpicEarthRemoteDataSource _remoteDataSource;
  final EpicEarthLocalDataSource _localDataSource;

  @override
  Future<Result<List<EpicImage>>> getLatestNaturalImages() async {
    try {
      final models = await _remoteDataSource.fetchLatestNaturalImages();
      await _ignoreCacheErrors(
        () => _localDataSource.cacheLatestImages(models),
      );
      return Success(_toEntities(models));
    } on AppException catch (error) {
      final cached = await _cachedImages(_localDataSource.getLatestImages);
      if (cached != null) {
        return Success(_toEntities(cached));
      }

      return Failure(error);
    } catch (error) {
      return Failure(
        AppException(
          type: AppExceptionType.unknown,
          message: 'Unexpected error while building EPIC Earth gallery.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<DateTime>>> getAvailableDates() async {
    try {
      final dates = await _remoteDataSource.fetchAvailableDates();
      await _ignoreCacheErrors(
        () => _localDataSource.cacheAvailableDates(dates),
      );
      return Success(dates);
    } on AppException catch (error) {
      final cached = await _cachedDates(_localDataSource.getAvailableDates);
      if (cached != null) {
        return Success(cached);
      }

      return Failure(error);
    } catch (error) {
      return Failure(
        AppException(
          type: AppExceptionType.unknown,
          message: 'Unexpected error while loading EPIC available dates.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<List<EpicImage>>> getNaturalImagesByDate(DateTime date) async {
    try {
      final models = await _remoteDataSource.fetchNaturalImagesByDate(date);
      await _ignoreCacheErrors(
        () => _localDataSource.cacheImagesByDate(date, models),
      );
      return Success(_toEntities(models));
    } on AppException catch (error) {
      final cached = await _cachedImages(
        () => _localDataSource.getImagesByDate(date),
      );
      if (cached != null) {
        return Success(_toEntities(cached));
      }

      return Failure(error);
    } catch (error) {
      return Failure(
        AppException(
          type: AppExceptionType.unknown,
          message: 'Unexpected error while loading EPIC images by date.',
          cause: error,
        ),
      );
    }
  }

  static List<EpicImage> _toEntities(List<EpicImageModel> models) {
    return models.map((model) => model.toEntity()).toList(growable: false);
  }

  static Future<List<EpicImageModel>?> _cachedImages(
    Future<List<EpicImageModel>?> Function() read,
  ) async {
    try {
      return await read();
    } catch (_) {
      return null;
    }
  }

  static Future<List<DateTime>?> _cachedDates(
    Future<List<DateTime>?> Function() read,
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
