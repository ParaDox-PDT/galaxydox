enum ApiKeySource { dartDefine, developmentFallback }

abstract final class AppConfig {
  static const String clientName = 'GalaxyDox';

  static const String nasaApiBaseUrl = 'https://api.nasa.gov';
  static const String nasaMediaBaseUrl = 'https://images-api.nasa.gov';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);

  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'X-App-Client': clientName,
  };

  static const String _envApiKey = String.fromEnvironment('NASA_API_KEY');
  static const String _devFallbackApiKey =
      'sTk3HV2cdO9ySYqQ5Gmc3ScwkLhKaPSxlp9AIxka';

  static String get nasaApiKey =>
      _envApiKey.isEmpty ? _devFallbackApiKey : _envApiKey;

  static ApiKeySource get apiKeySource => _envApiKey.isEmpty
      ? ApiKeySource.developmentFallback
      : ApiKeySource.dartDefine;

  static bool get isUsingFallbackApiKey =>
      apiKeySource == ApiKeySource.developmentFallback;

  static String get apiKeySourceLabel => switch (apiKeySource) {
    ApiKeySource.dartDefine => 'Injected with --dart-define',
    ApiKeySource.developmentFallback => 'Local development fallback',
  };
}

abstract final class RequestExtras {
  static const attachApiKey = 'attachApiKey';
}

abstract final class NasaEndpoints {
  static const apod = '/planetary/apod';
  static const nearEarthFeed = '/neo/rest/v1/feed';
  static const mediaSearch = '/search';

  static String marsRoverPhotos(String rover) =>
      '/mars-photos/api/v1/rovers/$rover/photos';
}
