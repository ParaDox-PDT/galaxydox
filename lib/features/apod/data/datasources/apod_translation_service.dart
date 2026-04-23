import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/apod_article_translation_model.dart';

final apodTranslationServiceProvider = Provider<ApodTranslationService>((ref) {
  final service = ApodTranslationService();
  ref.onDispose(service.dispose);
  return service;
});

class ApodTranslationService {
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();
  final Map<String, OnDeviceTranslator> _translators = {};

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool supportsLanguage(String languageCode) {
    return BCP47Code.fromRawValue(languageCode.trim().toLowerCase()) != null;
  }

  Future<ApodArticleTranslationModel> translateArticle({
    required String apodKey,
    required String sourceLanguageCode,
    required String targetLanguageCode,
    required String sourceContentHash,
    required String title,
    required String explanation,
  }) async {
    if (!isSupported) {
      throw const AppException(
        type: AppExceptionType.unknown,
        message: 'On-device translation is available on Android and iOS only.',
      );
    }

    final sourceLanguage = BCP47Code.fromRawValue(
      sourceLanguageCode.trim().toLowerCase(),
    );
    final targetLanguage = BCP47Code.fromRawValue(
      targetLanguageCode.trim().toLowerCase(),
    );

    if (sourceLanguage == null || targetLanguage == null) {
      throw const AppException(
        type: AppExceptionType.unknown,
        message: 'The selected translation language is not supported.',
      );
    }

    try {
      await _ensureModelAvailable(sourceLanguage);
      await _ensureModelAvailable(targetLanguage);

      final translator = _translatorFor(sourceLanguage, targetLanguage);
      final translatedTitle = title.trim().isEmpty
          ? title
          : await translator.translateText(title);
      final translatedExplanation = explanation.trim().isEmpty
          ? explanation
          : await _translateLargeText(translator, explanation);

      return ApodArticleTranslationModel(
        apodKey: apodKey,
        sourceLanguageCode: sourceLanguageCode,
        targetLanguageCode: targetLanguageCode,
        sourceContentHash: sourceContentHash,
        title: translatedTitle,
        explanation: translatedExplanation,
      );
    } on MissingPluginException {
      throw const AppException(
        type: AppExceptionType.unknown,
        message: 'On-device translation is available on Android and iOS only.',
      );
    } on PlatformException catch (error) {
      throw AppException(
        type: AppExceptionType.unknown,
        message: 'Failed to translate article.',
        cause: error,
      );
    } catch (error) {
      throw AppException(
        type: AppExceptionType.unknown,
        message: 'Failed to translate article.',
        cause: error,
      );
    }
  }

  void dispose() {
    for (final translator in _translators.values) {
      translator.close();
    }
    _translators.clear();
  }

  Future<void> _ensureModelAvailable(TranslateLanguage language) async {
    final code = language.bcpCode;
    final isDownloaded = await _modelManager.isModelDownloaded(code);
    if (isDownloaded) {
      return;
    }

    final downloaded = await _modelManager.downloadModel(
      code,
      isWifiRequired: false,
    );
    if (!downloaded) {
      throw const AppException(
        type: AppExceptionType.network,
        message: 'Failed to download the translation model.',
      );
    }
  }

  OnDeviceTranslator _translatorFor(
    TranslateLanguage sourceLanguage,
    TranslateLanguage targetLanguage,
  ) {
    final key = '${sourceLanguage.bcpCode}_${targetLanguage.bcpCode}';
    return _translators.putIfAbsent(
      key,
      () => OnDeviceTranslator(
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      ),
    );
  }

  Future<String> _translateLargeText(
    OnDeviceTranslator translator,
    String text,
  ) async {
    final chunks = _splitIntoChunks(text);
    if (chunks.length == 1) {
      return translator.translateText(chunks.single);
    }

    final buffer = StringBuffer();
    for (final chunk in chunks) {
      buffer.write(await translator.translateText(chunk));
    }

    return buffer.toString();
  }

  List<String> _splitIntoChunks(String text, {int maxChunkLength = 3500}) {
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
}
