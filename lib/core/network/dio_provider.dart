import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

final nasaApiDioProvider = Provider<Dio>((ref) {
  return _buildDio(
    baseUrl: AppConfig.nasaApiBaseUrl,
    attachApiKeyByDefault: true,
  );
});

final nasaMediaDioProvider = Provider<Dio>((ref) {
  return _buildDio(
    baseUrl: AppConfig.nasaMediaBaseUrl,
    attachApiKeyByDefault: false,
  );
});

Dio _buildDio({required String baseUrl, required bool attachApiKeyByDefault}) {
  final dio = Dio(_baseOptions(baseUrl));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final shouldAttachApiKey =
            options.extra[RequestExtras.attachApiKey] as bool? ??
            attachApiKeyByDefault;

        if (shouldAttachApiKey &&
            !options.queryParameters.containsKey('api_key')) {
          final apiKey = AppConfig.nasaApiKey;
          if (apiKey == null || apiKey.isEmpty) {
            handler.next(options);
            return;
          }

          final queryParameters = Map<String, dynamic>.from(
            options.queryParameters,
          );
          queryParameters['api_key'] = apiKey;
          options.queryParameters = queryParameters;
        }

        handler.next(options);
      },
    ),
  );

  return dio;
}

BaseOptions _baseOptions(String baseUrl) {
  return BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    sendTimeout: AppConfig.sendTimeout,
    responseType: ResponseType.json,
    headers: Map<String, dynamic>.from(AppConfig.defaultHeaders),
    listFormat: ListFormat.multiCompatible,
    validateStatus: (status) => status != null && status >= 200 && status < 500,
  );
}
