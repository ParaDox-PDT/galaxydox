enum ApiKeySource { dartDefine, debugDemoKey, missing }

abstract final class AppConfig {
  static const String clientName = 'GalaxyDox';
  static const bool isReleaseBuild = bool.fromEnvironment('dart.vm.product');

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
  static const String _debugFallbackApiKey = 'DEMO_KEY';
  static const String supportUrl = String.fromEnvironment('SUPPORT_URL');
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
  );
  static const String marketingUrl = String.fromEnvironment('MARKETING_URL');
  static const String sourceCodeUrl = String.fromEnvironment('SOURCE_CODE_URL');

  static String? get nasaApiKey {
    if (_envApiKey.isNotEmpty) {
      return _envApiKey;
    }

    if (!isReleaseBuild) {
      return _debugFallbackApiKey;
    }

    return null;
  }

  static ApiKeySource get apiKeySource {
    if (_envApiKey.isNotEmpty) {
      return ApiKeySource.dartDefine;
    }

    if (!isReleaseBuild) {
      return ApiKeySource.debugDemoKey;
    }

    return ApiKeySource.missing;
  }

  static bool get hasConfiguredNasaApiKey => _envApiKey.isNotEmpty;
  static bool get requiresProductionConfiguration =>
      isReleaseBuild && !hasConfiguredNasaApiKey;

  static String get apiKeySourceLabel => switch (apiKeySource) {
    ApiKeySource.dartDefine => 'Injected with --dart-define',
    ApiKeySource.debugDemoKey => 'Debug DEMO_KEY fallback',
    ApiKeySource.missing => 'Missing production API key',
  };

  static Uri? get supportUri => _parseHttpsUri(supportUrl);
  static Uri? get privacyPolicyUri => _parseHttpsUri(privacyPolicyUrl);
  static Uri? get marketingUri => _parseHttpsUri(marketingUrl);
  static Uri? get sourceCodeUri => _parseHttpsUri(sourceCodeUrl);

  static Uri? _parseHttpsUri(String value) {
    if (value.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'https') {
      return null;
    }

    return uri;
  }
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
