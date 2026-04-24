import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator/translator.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/translation/translation_language_options.dart';
import '../models/apod_article_translation_model.dart';

final apodTranslationServiceProvider = Provider<ApodTranslationService>((ref) {
  final service = ApodTranslationService();
  ref.onDispose(service.dispose);
  return service;
});

class ApodTranslationService {
  ApodTranslationService({
    GoogleTranslator? translator,
    Connectivity? connectivity,
  }) : _translator = translator ?? GoogleTranslator(),
       _connectivity = connectivity ?? Connectivity();

  static const Duration _translationTimeout = Duration(seconds: 18);

  final GoogleTranslator _translator;
  final Connectivity _connectivity;
  final Map<String, ApodArticleTranslationModel> _apodTranslationCache = {};

  bool get isSupported => true;

  bool supportsLanguage(String languageCode) {
    return TranslationLanguageOptions.normalizeCode(languageCode) != null;
  }

  Future<ApodArticleTranslationModel> translateArticle({
    required String apodKey,
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String sourceContentHash,
    required String title,
    required String explanation,
  }) async {
    final sourceLanguage = TranslationLanguageOptions.normalizeCode(
      sourceLanguageCode,
    );
    final targetLanguage = TranslationLanguageOptions.normalizeCode(
      targetLanguageCode,
    );

    if (sourceLanguage == null || targetLanguage == null) {
      throw const AppException(
        type: AppExceptionType.unknown,
        message: 'The selected translation language is not supported.',
      );
    }

    final cacheKey = _cacheKeyFor(
      apodKey: apodKey,
      targetLanguageCode: targetLanguage,
    );
    final cachedTranslation = _apodTranslationCache[cacheKey];
    if (cachedTranslation != null &&
        cachedTranslation.sourceContentHash == sourceContentHash) {
      return cachedTranslation;
    }

    if (sourceLanguage == targetLanguage) {
      return ApodArticleTranslationModel(
        apodKey: apodKey,
        sourceLanguageCode: sourceLanguage,
        targetLanguageCode: targetLanguage,
        sourceContentHash: sourceContentHash,
        title: title,
        explanation: explanation,
      );
    }

    try {
      final hasConnection = await _hasNetworkConnection();
      if (!hasConnection) {
        throw const AppException(
          type: AppExceptionType.network,
          message: 'Internet connection is required for translation.',
        );
      }

      final translatedTitle = title.trim().isEmpty
          ? title
          : await _translateText(
              text: title,
              sourceLanguageCode: sourceLanguage,
              targetLanguageCode: targetLanguage,
            );
      final translatedExplanation = explanation.trim().isEmpty
          ? explanation
          : await _translateLargeText(
              text: explanation,
              sourceLanguageCode: sourceLanguage,
              targetLanguageCode: targetLanguage,
            );

      final translation = ApodArticleTranslationModel(
        apodKey: apodKey,
        sourceLanguageCode: sourceLanguage,
        targetLanguageCode: targetLanguage,
        sourceContentHash: sourceContentHash,
        title: translatedTitle,
        explanation: translatedExplanation,
      );

      _apodTranslationCache[cacheKey] = translation;
      return translation;
    } on AppException {
      rethrow;
    } on TimeoutException catch (error) {
      throw AppException(
        type: AppExceptionType.timeout,
        message:
            'Translation took too long. Check your internet connection and try again.',
        cause: error,
      );
    } catch (error) {
      throw AppException(
        type: AppExceptionType.network,
        message:
            "Couldn't translate this article. Check your internet connection and try again.",
        cause: error,
      );
    }
  }

  void dispose() {
    _apodTranslationCache.clear();
  }

  Future<bool> _hasNetworkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  Future<String> _translateText({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  }) async {
    if (text.trim().isEmpty || sourceLanguageCode == targetLanguageCode) {
      return text;
    }

    final result = await _translator
        .translate(text, from: sourceLanguageCode, to: targetLanguageCode)
        .timeout(_translationTimeout);

    return result.text;
  }

  Future<String> _translateLargeText({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  }) async {
    final chunks = _splitIntoChunks(text);
    if (chunks.length == 1) {
      return _translateText(
        text: chunks.single,
        sourceLanguageCode: sourceLanguageCode,
        targetLanguageCode: targetLanguageCode,
      );
    }

    final buffer = StringBuffer();
    for (final chunk in chunks) {
      buffer.write(
        await _translateText(
          text: chunk,
          sourceLanguageCode: sourceLanguageCode,
          targetLanguageCode: targetLanguageCode,
        ),
      );
    }

    return buffer.toString();
  }

  List<String> _splitIntoChunks(String text, {int maxChunkLength = 1800}) {
    final normalized = text.replaceAll('\r\n', '\n');
    if (normalized.length <= maxChunkLength) {
      return [normalized];
    }

    final chunks = <String>[];
    var start = 0;

    while (start < normalized.length) {
      var end = start + maxChunkLength;
      if (end >= normalized.length) {
        chunks.add(normalized.substring(start));
        break;
      }

      end = _findChunkBoundary(normalized, start, end);
      if (end <= start) {
        end = (start + maxChunkLength).clamp(0, normalized.length);
      }

      chunks.add(normalized.substring(start, end));
      start = end;
    }

    return chunks;
  }

  int _findChunkBoundary(String text, int start, int tentativeEnd) {
    final minimumBoundary = start + ((tentativeEnd - start) ~/ 2);
    final tokens = <String>['\n\n', '. ', '! ', '? ', '\n', ' '];

    for (final token in tokens) {
      final index = text.lastIndexOf(token, tentativeEnd);
      if (index >= minimumBoundary) {
        return index + token.length;
      }
    }

    return tentativeEnd;
  }

  static String _cacheKeyFor({
    required String apodKey,
    required String targetLanguageCode,
  }) {
    return '${apodKey.trim().toLowerCase()}__${targetLanguageCode.trim().toLowerCase()}';
  }
}
