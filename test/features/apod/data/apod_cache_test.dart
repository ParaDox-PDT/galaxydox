import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:galaxydox/core/errors/app_exception.dart';
import 'package:galaxydox/features/apod/data/datasources/apod_local_data_source.dart';
import 'package:galaxydox/features/apod/data/datasources/apod_remote_data_source.dart';
import 'package:galaxydox/features/apod/data/models/apod_model.dart';
import 'package:galaxydox/features/apod/data/repositories/apod_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApodLocalDataSourceImpl', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('apod_cache_test');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      if (Hive.isBoxOpen(ApodLocalDataSourceImpl.boxName)) {
        await Hive.box<String>(ApodLocalDataSourceImpl.boxName).close();
      }
      await Hive.deleteBoxFromDisk(ApodLocalDataSourceImpl.boxName);
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test('returns an APOD cached for a specific selected date', () async {
      const dataSource = ApodLocalDataSourceImpl();
      final model = _apodModel(date: DateTime(2026, 4, 17));

      await dataSource.cacheApod(
        model,
        requestedDate: DateTime(2026, 4, 17, 18, 45),
      );

      final cached = await dataSource.getApod(
        requestedDate: DateTime(2026, 4, 17, 7, 30),
      );

      expect(cached?.title, model.title);
      expect(cached?.date, model.date);
    });

    test('keeps latest lookup and actual APOD date both searchable', () async {
      const dataSource = ApodLocalDataSourceImpl();
      final model = _apodModel(date: DateTime(2026, 4, 17));

      await dataSource.cacheApod(model);

      final cachedLatest = await dataSource.getApod();
      final cachedByDate = await dataSource.getApod(requestedDate: model.date);

      expect(cachedLatest?.title, model.title);
      expect(cachedByDate?.title, model.title);
    });
  });

  group('ApodRepositoryImpl', () {
    test('returns cached APOD without hitting the API again', () async {
      final localDataSource = _FakeApodLocalDataSource(
        cached: _apodModel(date: DateTime(2026, 4, 17), title: 'Cached APOD'),
      );
      final remoteDataSource = _FakeApodRemoteDataSource(
        response: _apodModel(date: DateTime(2026, 4, 18), title: 'Remote APOD'),
      );
      final repository = ApodRepositoryImpl(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );

      final result = await repository.getApod(date: DateTime(2026, 4, 17));

      expect(remoteDataSource.callCount, 0);
      expect(localDataSource.cachedWrites, isEmpty);
      expect(
        result.when(success: (item) => item?.title, failure: (_) => null),
        'Cached APOD',
      );
    });

    test('force refresh bypasses cache and stores the remote result', () async {
      final remoteModel = _apodModel(
        date: DateTime(2026, 4, 18),
        title: 'Fresh Remote APOD',
      );
      final localDataSource = _FakeApodLocalDataSource(
        cached: _apodModel(date: DateTime(2026, 4, 17), title: 'Old Cache'),
      );
      final remoteDataSource = _FakeApodRemoteDataSource(response: remoteModel);
      final repository = ApodRepositoryImpl(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );

      final result = await repository.getApod(
        date: DateTime(2026, 4, 18),
        forceRefresh: true,
      );

      expect(remoteDataSource.callCount, 1);
      expect(
        localDataSource.cachedWrites.single.model.title,
        remoteModel.title,
      );
      expect(
        localDataSource.cachedWrites.single.requestedDate,
        DateTime(2026, 4, 18),
      );
      expect(
        result.when(success: (item) => item?.title, failure: (_) => null),
        'Fresh Remote APOD',
      );
    });

    test('falls back to cached APOD when refresh fails', () async {
      final localDataSource = _FakeApodLocalDataSource(
        cached: _apodModel(date: DateTime(2026, 4, 17), title: 'Offline Cache'),
      );
      final remoteDataSource = _FakeApodRemoteDataSource(
        exception: const AppException(
          type: AppExceptionType.network,
          message: 'Unable to reach NASA APOD right now.',
        ),
      );
      final repository = ApodRepositoryImpl(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );

      final result = await repository.getApod(
        date: DateTime(2026, 4, 17),
        forceRefresh: true,
      );

      expect(remoteDataSource.callCount, 1);
      expect(
        result.when(success: (item) => item?.title, failure: (_) => null),
        'Offline Cache',
      );
    });
  });
}

ApodModel _apodModel({required DateTime date, String title = 'Test APOD'}) {
  return ApodModel(
    date: date,
    title: title,
    explanation: 'A test explanation',
    mediaType: 'image',
    url: 'https://example.com/apod.jpg',
    hdUrl: 'https://example.com/apod_hd.jpg',
    thumbnailUrl: 'https://example.com/apod_thumb.jpg',
    copyright: 'NASA',
  );
}

class _FakeApodLocalDataSource implements ApodLocalDataSource {
  _FakeApodLocalDataSource({this.cached});

  final ApodModel? cached;
  final List<_CachedWrite> cachedWrites = [];

  @override
  Future<void> cacheApod(ApodModel model, {DateTime? requestedDate}) async {
    cachedWrites.add(_CachedWrite(model: model, requestedDate: requestedDate));
  }

  @override
  Future<ApodModel?> getApod({DateTime? requestedDate}) async {
    return cached;
  }
}

class _FakeApodRemoteDataSource implements ApodRemoteDataSource {
  _FakeApodRemoteDataSource({this.response, this.exception});

  final ApodModel? response;
  final AppException? exception;
  int callCount = 0;

  @override
  Future<ApodModel?> fetchApod({DateTime? date}) async {
    callCount++;
    final exception = this.exception;
    if (exception != null) {
      throw exception;
    }

    return response;
  }
}

class _CachedWrite {
  const _CachedWrite({required this.model, required this.requestedDate});

  final ApodModel model;
  final DateTime? requestedDate;
}
