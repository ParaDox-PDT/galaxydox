import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/apod_article_translation.dart';
import '../../domain/entities/apod_item.dart';
import '../../domain/repositories/apod_translation_repository.dart';
import '../datasources/apod_translation_local_data_source.dart';
import '../datasources/apod_translation_service.dart';
import '../models/apod_article_translation_model.dart';

final apodTranslationRepositoryProvider = Provider<ApodTranslationRepository>((
  ref,
) {
  return ApodTranslationRepositoryImpl(
    localDataSource: ref.watch(apodTranslationLocalDataSourceProvider),
    translationService: ref.watch(apodTranslationServiceProvider),
  );
});

class ApodTranslationRepositoryImpl implements ApodTranslationRepository {
  const ApodTranslationRepositoryImpl({
    required ApodTranslationLocalDataSource localDataSource,
    required ApodTranslationService translationService,
  }) : _localDataSource = localDataSource,
       _translationService = translationService;

  final ApodTranslationLocalDataSource _localDataSource;
  final ApodTranslationService _translationService;

  @override
  bool get isTranslationSupported => _translationService.isSupported;

  @override
  bool supportsLanguage(String languageCode) {
    return _translationService.supportsLanguage(languageCode);
  }

  @override
  Future<Result<ApodArticleTranslation>> translateArticle({
    required ApodItem item,
    required String targetLanguageCode,
  }) async {
    try {
      final cached = await _cachedTranslation(() {
        return _localDataSource.getTranslation(
          item: item,
          targetLanguageCode: targetLanguageCode,
        );
      });
      if (cached != null) {
        return Success(cached.toEntity());
      }

      final model = await _translationService.translateArticle(
        apodKey: ApodTranslationLocalDataSourceImpl.apodKeyFor(item.date),
        sourceLanguageCode: 'en',
        targetLanguageCode: targetLanguageCode,
        sourceContentHash:
            ApodTranslationLocalDataSourceImpl.sourceContentHashFor(item),
        title: item.title,
        explanation: item.explanation,
      );

      await _ignoreCacheErrors(() {
        return _localDataSource.cacheTranslation(
          item: item,
          translation: model,
        );
      });

      return Success(model.toEntity());
    } on AppException catch (error) {
      return Failure(error);
    } catch (error) {
      return Failure(
        AppException(
          type: AppExceptionType.unknown,
          message:
              "Couldn't translate this article. Check your internet connection and try again.",
          cause: error,
        ),
      );
    }
  }

  static Future<ApodArticleTranslationModel?> _cachedTranslation(
    Future<ApodArticleTranslationModel?> Function() read,
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
