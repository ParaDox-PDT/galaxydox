import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/translation/translation_language_options.dart';

class SettingsLocalDataSource {
  static const boxName = 'app_preferences';
  static const _apodTranslationLanguageKey = 'apod_translation_language_code';

  Box<dynamic> get _box => Hive.box<dynamic>(boxName);

  TranslationLanguageOption readApodTranslationLanguage() {
    final stored = _box.get(_apodTranslationLanguageKey) as String?;
    return TranslationLanguageOptions.fromCode(stored) ??
        TranslationLanguageOptions.resolveInitialOption();
  }

  Future<void> saveApodTranslationLanguageCode(String code) async {
    final normalized = TranslationLanguageOptions.fromCode(code)?.code;
    if (normalized == null) {
      return;
    }

    final current = (_box.get(_apodTranslationLanguageKey) as String?)?.trim();
    if (current == normalized) {
      return;
    }

    await _box.put(_apodTranslationLanguageKey, normalized);
  }
}
