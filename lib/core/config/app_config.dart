abstract final class AppConfig {
  static const String nasaApiBaseUrl = 'https://api.nasa.gov';
  static const String nasaMediaBaseUrl = 'https://images-api.nasa.gov';

  static const String _envApiKey = String.fromEnvironment('NASA_API_KEY');
  static const String _devFallbackApiKey =
      'sTk3HV2cdO9ySYqQ5Gmc3ScwkLhKaPSxlp9AIxka';

  static String get nasaApiKey =>
      _envApiKey.isEmpty ? _devFallbackApiKey : _envApiKey;

  static bool get isUsingFallbackApiKey => _envApiKey.isEmpty;

  static String get apiKeySourceLabel => isUsingFallbackApiKey
      ? 'Local development fallback'
      : 'Injected with --dart-define';
}
