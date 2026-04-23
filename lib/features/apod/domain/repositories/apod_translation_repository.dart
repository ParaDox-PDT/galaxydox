import '../../../../core/errors/result.dart';
import '../entities/apod_article_translation.dart';
import '../entities/apod_item.dart';

abstract interface class ApodTranslationRepository {
  bool get isTranslationSupported;

  bool supportsLanguage(String languageCode);

  Future<Result<ApodArticleTranslation>> translateArticle({
    required ApodItem item,
    required String targetLanguageCode,
  });
}
