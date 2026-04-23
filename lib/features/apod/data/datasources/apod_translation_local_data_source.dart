import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/apod_item.dart';
import '../models/apod_article_translation_model.dart';

final apodTranslationLocalDataSourceProvider =
    Provider<ApodTranslationLocalDataSource>((ref) {
      return const ApodTranslationLocalDataSourceImpl();
    });

abstract interface class ApodTranslationLocalDataSource {
  Future<ApodArticleTranslationModel?> getTranslation({
    required ApodItem item,
    required String targetLanguageCode,
  });

  Future<void> cacheTranslation({
    required ApodItem item,
    required ApodArticleTranslationModel translation,
  });
}

class ApodTranslationLocalDataSourceImpl
    implements ApodTranslationLocalDataSource {
  const ApodTranslationLocalDataSourceImpl();

  static const boxName = 'apod_translation_cache';
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<ApodArticleTranslationModel?> getTranslation({
    required ApodItem item,
    required String targetLanguageCode,
  }) async {
    final key = cacheKeyFor(item: item, targetLanguageCode: targetLanguageCode);
    final expectedHash = sourceContentHashFor(item);

    try {
      final raw = (await _box).get(key);
      if (raw == null) {
        return null;
      }

      final decoded = jsonDecode(raw);
      final model = ApodArticleTranslationModel.fromJson(
        Map<String, dynamic>.from(decoded as Map),
      );

      if (model.sourceContentHash != expectedHash) {
        await _delete(key);
        return null;
      }

      return model;
    } catch (error) {
      await _delete(key);
      throw AppException(
        type: AppExceptionType.storage,
        message: 'Cached APOD translation could not be read.',
        cause: error,
      );
    }
  }

  @override
  Future<void> cacheTranslation({
    required ApodItem item,
    required ApodArticleTranslationModel translation,
  }) async {
    final key = cacheKeyFor(
      item: item,
      targetLanguageCode: translation.targetLanguageCode,
    );

    try {
      await (await _box).put(key, jsonEncode(translation.toJson()));
    } catch (error) {
      throw AppException(
        type: AppExceptionType.storage,
        message: 'Translated APOD content could not be cached on this device.',
        cause: error,
      );
    }
  }

  Future<void> _delete(String key) async {
    if (!Hive.isBoxOpen(boxName)) {
      return;
    }

    await Hive.box<String>(boxName).delete(key);
  }

  Future<Box<String>> get _box async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<String>(boxName);
      }

      return Hive.openBox<String>(boxName);
    } catch (error) {
      throw AppException(
        type: AppExceptionType.storage,
        message: 'APOD translation cache could not be opened.',
        cause: error,
      );
    }
  }

  static String apodKeyFor(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _dateFormat.format(normalized);
  }

  static String cacheKeyFor({
    required ApodItem item,
    required String targetLanguageCode,
  }) {
    return 'apod_${apodKeyFor(item.date)}__lang_${targetLanguageCode.trim().toLowerCase()}';
  }

  static String sourceContentHashFor(ApodItem item) {
    const offsetBasis = 0x811c9dc5;
    const prime = 0x01000193;
    var hash = offsetBasis;
    final payload = utf8.encode('${item.title}\u0000${item.explanation}');

    for (final byte in payload) {
      hash ^= byte;
      hash = (hash * prime) & 0xffffffff;
    }

    return hash.toRadixString(16).padLeft(8, '0');
  }
}
