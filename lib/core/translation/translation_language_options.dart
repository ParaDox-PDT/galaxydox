class TranslationLanguageOption {
  const TranslationLanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  final String code;
  final String name;
  final String nativeName;

  String get label => name;

  bool get isEnglish => code == 'en';
}

abstract final class TranslationLanguageOptions {
  static const List<TranslationLanguageOption> values = [
    TranslationLanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
    ),
    TranslationLanguageOption(
      code: 'ru',
      name: 'Russian',
      nativeName: 'Русский',
    ),
    TranslationLanguageOption(code: 'uz', name: 'Uzbek', nativeName: 'Oʻzbek'),
    TranslationLanguageOption(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
    ),
    TranslationLanguageOption(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    TranslationLanguageOption(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
    ),
    TranslationLanguageOption(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
    ),
    TranslationLanguageOption(
      code: 'it',
      name: 'Italian',
      nativeName: 'Italiano',
    ),
    TranslationLanguageOption(
      code: 'pt',
      name: 'Portuguese',
      nativeName: 'Português',
    ),
    TranslationLanguageOption(
      code: 'tr',
      name: 'Turkish',
      nativeName: 'Türkçe',
    ),
    TranslationLanguageOption(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
    ),
    TranslationLanguageOption(
      code: 'zh-cn',
      name: 'Chinese Simplified',
      nativeName: '简体中文',
    ),
    TranslationLanguageOption(code: 'ja', name: 'Japanese', nativeName: '日本語'),
    TranslationLanguageOption(code: 'ko', name: 'Korean', nativeName: '한국어'),
    TranslationLanguageOption(
      code: 'zh-tw',
      name: 'Chinese Traditional',
      nativeName: '繁體中文',
    ),
    TranslationLanguageOption(
      code: 'id',
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
    ),
    TranslationLanguageOption(
      code: 'ms',
      name: 'Malay',
      nativeName: 'Bahasa Melayu',
    ),
    TranslationLanguageOption(
      code: 'vi',
      name: 'Vietnamese',
      nativeName: 'Tiếng Việt',
    ),
    TranslationLanguageOption(code: 'th', name: 'Thai', nativeName: 'ไทย'),
    TranslationLanguageOption(code: 'fa', name: 'Persian', nativeName: 'فارسی'),
    TranslationLanguageOption(code: 'ur', name: 'Urdu', nativeName: 'اردو'),
    TranslationLanguageOption(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    TranslationLanguageOption(
      code: 'pa',
      name: 'Punjabi',
      nativeName: 'ਪੰਜਾਬੀ',
    ),
    TranslationLanguageOption(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    TranslationLanguageOption(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    TranslationLanguageOption(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    TranslationLanguageOption(
      code: 'gu',
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
    ),
    TranslationLanguageOption(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    TranslationLanguageOption(
      code: 'uk',
      name: 'Ukrainian',
      nativeName: 'Українська',
    ),
    TranslationLanguageOption(code: 'pl', name: 'Polish', nativeName: 'Polski'),
    TranslationLanguageOption(
      code: 'nl',
      name: 'Dutch',
      nativeName: 'Nederlands',
    ),
    TranslationLanguageOption(
      code: 'ro',
      name: 'Romanian',
      nativeName: 'Română',
    ),
    TranslationLanguageOption(code: 'cs', name: 'Czech', nativeName: 'Čeština'),
    TranslationLanguageOption(
      code: 'el',
      name: 'Greek',
      nativeName: 'Ελληνικά',
    ),
    TranslationLanguageOption(
      code: 'sv',
      name: 'Swedish',
      nativeName: 'Svenska',
    ),
    TranslationLanguageOption(
      code: 'no',
      name: 'Norwegian',
      nativeName: 'Norsk',
    ),
    TranslationLanguageOption(code: 'da', name: 'Danish', nativeName: 'Dansk'),
    TranslationLanguageOption(code: 'fi', name: 'Finnish', nativeName: 'Suomi'),
    TranslationLanguageOption(code: 'he', name: 'Hebrew', nativeName: 'עברית'),
    TranslationLanguageOption(
      code: 'sw',
      name: 'Swahili',
      nativeName: 'Kiswahili',
    ),
    TranslationLanguageOption(code: 'am', name: 'Amharic', nativeName: 'አማርኛ'),
    TranslationLanguageOption(
      code: 'hu',
      name: 'Hungarian',
      nativeName: 'Magyar',
    ),
    TranslationLanguageOption(
      code: 'sk',
      name: 'Slovak',
      nativeName: 'Slovenčina',
    ),
    TranslationLanguageOption(
      code: 'bg',
      name: 'Bulgarian',
      nativeName: 'Български',
    ),
    TranslationLanguageOption(
      code: 'sr',
      name: 'Serbian',
      nativeName: 'Српски',
    ),
    TranslationLanguageOption(
      code: 'hr',
      name: 'Croatian',
      nativeName: 'Hrvatski',
    ),
  ];

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

    final trimmed = code.trim().toLowerCase().replaceAll('_', '-');
    if (trimmed.isEmpty) {
      return null;
    }

    if (_byCode.containsKey(trimmed)) {
      return trimmed;
    }

    if (trimmed == 'zh' || trimmed.startsWith('zh-hans')) {
      return 'zh-cn';
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
}
