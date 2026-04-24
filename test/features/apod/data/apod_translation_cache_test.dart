import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:galaxydox/features/apod/data/datasources/apod_translation_local_data_source.dart';
import 'package:galaxydox/features/apod/data/datasources/apod_translation_service.dart';
import 'package:galaxydox/features/apod/data/models/apod_article_translation_model.dart';
import 'package:galaxydox/features/apod/data/repositories/apod_translation_repository_impl.dart';
import 'package:galaxydox/features/apod/domain/entities/apod_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApodTranslationLocalDataSourceImpl', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'apod_translation_cache_test',
      );
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      if (Hive.isBoxOpen(ApodTranslationLocalDataSourceImpl.boxName)) {
        await Hive.box<String>(
          ApodTranslationLocalDataSourceImpl.boxName,
        ).close();
      }
      await Hive.deleteBoxFromDisk(ApodTranslationLocalDataSourceImpl.boxName);
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test(
      'returns a cached translation for the same APOD and language',
      () async {
        const dataSource = ApodTranslationLocalDataSourceImpl();
        final item = _apodItem();
        final translation = _translationModel(item: item, languageCode: 'es');

        await dataSource.cacheTranslation(item: item, translation: translation);

        final cached = await dataSource.getTranslation(
          item: item,
          targetLanguageCode: 'es',
        );

        expect(cached?.title, translation.title);
        expect(cached?.explanation, translation.explanation);
      },
    );

    test(
      'invalidates stale cached translations after source text changes',
      () async {
        const dataSource = ApodTranslationLocalDataSourceImpl();
        final originalItem = _apodItem();
        final updatedItem = _apodItem(
          title: 'Updated APOD title',
          explanation: 'Updated APOD explanation',
        );

        await dataSource.cacheTranslation(
          item: originalItem,
          translation: _translationModel(
            item: originalItem,
            languageCode: 'fr',
          ),
        );

        final cached = await dataSource.getTranslation(
          item: updatedItem,
          targetLanguageCode: 'fr',
        );

        expect(cached, isNull);
      },
    );
  });

  group('ApodTranslationRepositoryImpl', () {
    test(
      'returns cached translation without invoking the translator again',
      () async {
        final item = _apodItem();
        final cachedModel = _translationModel(item: item, languageCode: 'es');
        final localDataSource = _FakeApodTranslationLocalDataSource(
          cached: cachedModel,
        );
        final translationService = _FakeApodTranslationService(
          response: _translationModel(item: item, languageCode: 'es'),
        );
        final repository = ApodTranslationRepositoryImpl(
          localDataSource: localDataSource,
          translationService: translationService,
        );

        final result = await repository.translateArticle(
          item: item,
          targetLanguageCode: 'es',
        );

        expect(translationService.callCount, 0);
        expect(localDataSource.cachedWrites, isEmpty);
        expect(
          result.when(
            success: (translation) => translation.title,
            failure: (_) => null,
          ),
          cachedModel.title,
        );
      },
    );

    test('translates and caches when no cached translation exists', () async {
      final item = _apodItem();
      final translatedModel = _translationModel(item: item, languageCode: 'de');
      final localDataSource = _FakeApodTranslationLocalDataSource();
      final translationService = _FakeApodTranslationService(
        response: translatedModel,
      );
      final repository = ApodTranslationRepositoryImpl(
        localDataSource: localDataSource,
        translationService: translationService,
      );

      final result = await repository.translateArticle(
        item: item,
        targetLanguageCode: 'de',
      );

      expect(translationService.callCount, 1);
      expect(
        localDataSource.cachedWrites.single.translation.title,
        translatedModel.title,
      );
      expect(
        result.when(
          success: (translation) => translation.title,
          failure: (_) => null,
        ),
        translatedModel.title,
      );
    });
  });
}

ApodItem _apodItem({
  DateTime? date,
  String title = 'Galaxy over the mountains',
  String explanation = 'A calm APOD explanation for testing.',
}) {
  return ApodItem(
    date: date ?? DateTime(2026, 4, 20),
    title: title,
    explanation: explanation,
    mediaType: ApodMediaType.image,
    url: 'https://example.com/apod.jpg',
    hdUrl: 'https://example.com/apod_hd.jpg',
    thumbnailUrl: 'https://example.com/apod_thumb.jpg',
    copyright: 'NASA',
  );
}

ApodArticleTranslationModel _translationModel({
  required ApodItem item,
  required String languageCode,
}) {
  return ApodArticleTranslationModel(
    apodKey: ApodTranslationLocalDataSourceImpl.apodKeyFor(item.date),
    sourceLanguageCode: 'en',
    targetLanguageCode: languageCode,
    sourceContentHash: ApodTranslationLocalDataSourceImpl.sourceContentHashFor(
      item,
    ),
    title: 'Translated ${item.title}',
    explanation: 'Translated ${item.explanation}',
  );
}

class _FakeApodTranslationLocalDataSource
    implements ApodTranslationLocalDataSource {
  _FakeApodTranslationLocalDataSource({this.cached});

  final ApodArticleTranslationModel? cached;
  final List<_CachedTranslationWrite> cachedWrites = [];

  @override
  Future<void> cacheTranslation({
    required ApodItem item,
    required ApodArticleTranslationModel translation,
  }) async {
    cachedWrites.add(
      _CachedTranslationWrite(item: item, translation: translation),
    );
  }

  @override
  Future<ApodArticleTranslationModel?> getTranslation({
    required ApodItem item,
    required String targetLanguageCode,
  }) async {
    return cached;
  }
}

class _FakeApodTranslationService extends ApodTranslationService {
  _FakeApodTranslationService({this.response});

  final ApodArticleTranslationModel? response;
  int callCount = 0;

  @override
  bool get isSupported => true;

  @override
  bool supportsLanguage(String languageCode) => true;

  @override
  Future<ApodArticleTranslationModel> translateArticle({
    required String apodKey,
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String sourceContentHash,
    required String title,
    required String explanation,
  }) async {
    callCount++;
    return response!;
  }

  @override
  void dispose() {}
}

class _CachedTranslationWrite {
  const _CachedTranslationWrite({
    required this.item,
    required this.translation,
  });

  final ApodItem item;
  final ApodArticleTranslationModel translation;
}
