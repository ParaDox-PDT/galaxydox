import '../../domain/entities/apod_article_translation.dart';

class ApodArticleTranslationModel {
  const ApodArticleTranslationModel({
    required this.apodKey,
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
    required this.sourceContentHash,
    required this.title,
    required this.explanation,
  });

  factory ApodArticleTranslationModel.fromJson(Map<String, dynamic> json) {
    return ApodArticleTranslationModel(
      apodKey: json['apodKey'] as String? ?? '',
      sourceLanguageCode: json['sourceLanguageCode'] as String? ?? 'en',
      targetLanguageCode: json['targetLanguageCode'] as String? ?? '',
      sourceContentHash: json['sourceContentHash'] as String? ?? '',
      title: json['title'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }

  factory ApodArticleTranslationModel.fromEntity(
    ApodArticleTranslation translation,
  ) {
    return ApodArticleTranslationModel(
      apodKey: translation.apodKey,
      sourceLanguageCode: translation.sourceLanguageCode,
      targetLanguageCode: translation.targetLanguageCode,
      sourceContentHash: translation.sourceContentHash,
      title: translation.title,
      explanation: translation.explanation,
    );
  }

  final String apodKey;
  final String sourceLanguageCode;
  final String targetLanguageCode;
  final String sourceContentHash;
  final String title;
  final String explanation;

  Map<String, dynamic> toJson() {
    return {
      'apodKey': apodKey,
      'sourceLanguageCode': sourceLanguageCode,
      'targetLanguageCode': targetLanguageCode,
      'sourceContentHash': sourceContentHash,
      'title': title,
      'explanation': explanation,
    };
  }

  ApodArticleTranslation toEntity() {
    return ApodArticleTranslation(
      apodKey: apodKey,
      sourceLanguageCode: sourceLanguageCode,
      targetLanguageCode: targetLanguageCode,
      sourceContentHash: sourceContentHash,
      title: title,
      explanation: explanation,
    );
  }
}
