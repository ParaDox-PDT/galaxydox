import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator/translator.dart';

import '../errors/app_exception.dart';
import 'translation_language_options.dart';

final textTranslationServiceProvider = Provider<TextTranslationService>((ref) {
  final service = TextTranslationService();
  ref.onDispose(service.dispose);
  return service;
});

class TextTranslationService {
  TextTranslationService({
    GoogleTranslator? translator,
    Connectivity? connectivity,
  }) : _translator = translator ?? GoogleTranslator(),
       _connectivity = connectivity ?? Connectivity();

  static const Duration _translationTimeout = Duration(seconds: 18);

  final GoogleTranslator _translator;
  final Connectivity _connectivity;
  final Map<String, String> _textCache = {};

  bool supportsLanguage(String languageCode) {
    return TranslationLanguageOptions.normalizeCode(languageCode) != null;
  }

  Future<String> translateText({
    required String text,
    required String targetLanguageCode,
    String sourceLanguageCode = 'en',
  }) async {
    if (text.trim().isEmpty) {
      return text;
    }

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

    if (sourceLanguage == targetLanguage) {
      return text;
    }

    final cacheKey = _cacheKeyFor(
      text: text,
      sourceLanguageCode: sourceLanguage,
      targetLanguageCode: targetLanguage,
    );
    final cached = _textCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    try {
      final hasConnection = await _hasNetworkConnection();
      if (!hasConnection) {
        throw const AppException(
          type: AppExceptionType.network,
          message: 'Internet connection is required for translation.',
        );
      }

      final translated = await _translateLargeText(
        text: text,
        sourceLanguageCode: sourceLanguage,
        targetLanguageCode: targetLanguage,
      );

      _textCache[cacheKey] = translated;
      return translated;
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
            "Couldn't translate this text. Check your internet connection and try again.",
        cause: error,
      );
    }
  }

  void dispose() {
    _textCache.clear();
  }

  Future<bool> _hasNetworkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  Future<String> _translateLargeText({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  }) async {
    final chunks = _splitIntoChunks(text);
    if (chunks.length == 1) {
      return _translateChunk(
        text: chunks.single,
        sourceLanguageCode: sourceLanguageCode,
        targetLanguageCode: targetLanguageCode,
      );
    }

    final buffer = StringBuffer();
    for (final chunk in chunks) {
      buffer.write(
        await _translateChunk(
          text: chunk,
          sourceLanguageCode: sourceLanguageCode,
          targetLanguageCode: targetLanguageCode,
        ),
      );
    }

    return buffer.toString();
  }

  Future<String> _translateChunk({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  }) async {
    final result = await _translator
        .translate(text, from: sourceLanguageCode, to: targetLanguageCode)
        .timeout(_translationTimeout);

    return result.text;
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
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  }) {
    return '$sourceLanguageCode:$targetLanguageCode:${_stableHashFor(text)}';
  }

  static String _stableHashFor(String value) {
    const offsetBasis = 0x811c9dc5;
    const prime = 0x01000193;
    var hash = offsetBasis;

    for (final byte in utf8.encode(value)) {
      hash ^= byte;
      hash = (hash * prime) & 0xffffffff;
    }

    return hash.toRadixString(16).padLeft(8, '0');
  }
}
