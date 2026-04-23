class ApodArticleTranslation {
  const ApodArticleTranslation({
    required this.apodKey,
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
    required this.sourceContentHash,
    required this.title,
    required this.explanation,
  });

  final String apodKey;
  final String sourceLanguageCode;
  final String targetLanguageCode;
  final String sourceContentHash;
  final String title;
  final String explanation;
}
