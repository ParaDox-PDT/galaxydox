import '../../../../core/errors/result.dart';
import '../entities/apod_article_translation.dart';
import '../entities/apod_item.dart';
import '../repositories/apod_translation_repository.dart';

class TranslateApodArticleUseCase {
  const TranslateApodArticleUseCase(this._repository);

  final ApodTranslationRepository _repository;

  bool get isTranslationSupported => _repository.isTranslationSupported;

  bool supportsLanguage(String languageCode) =>
      _repository.supportsLanguage(languageCode);

  Future<Result<ApodArticleTranslation>> call({
    required ApodItem item,
    required String targetLanguageCode,
  }) {
    return _repository.translateArticle(
      item: item,
      targetLanguageCode: targetLanguageCode,
    );
  }
}
