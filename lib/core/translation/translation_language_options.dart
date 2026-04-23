import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationLanguageOption {
  const TranslationLanguageOption({required this.code, required this.label});

  final String code;
  final String label;

  bool get isEnglish => code == 'en';
}

abstract final class TranslationLanguageOptions {
  static final List<TranslationLanguageOption> values = TranslateLanguage.values
      .map(
        (language) => TranslationLanguageOption(
          code: language.bcpCode,
          label: _humanize(language.name),
        ),
      )
      .toList(growable: false);

  static final Map<String, TranslationLanguageOption> _byCode = {
    for (final option in values) option.code: option,
  };

  static TranslationLanguageOption get english => _byCode['en']!;
  static TranslationLanguageOption get russian => _byCode['ru']!;

  static TranslationLanguageOption? fromCode(String? code) {
    final normalized = normalizeCode(code);
    if (normalized == null) {
      return null;
    }

    return _byCode[normalized];
  }

  static String? normalizeCode(String? code) {
    if (code == null) {
      return null;
    }

    final trimmed = code.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return null;
    }

    if (_byCode.containsKey(trimmed)) {
      return trimmed;
    }

    final separatorIndex = trimmed.indexOf(RegExp(r'[-_]'));
    if (separatorIndex <= 0) {
      return null;
    }

    final base = trimmed.substring(0, separatorIndex);
    return _byCode.containsKey(base) ? base : null;
  }

  static TranslationLanguageOption resolveInitialOption() {
    return russian;
  }

  static String _humanize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
