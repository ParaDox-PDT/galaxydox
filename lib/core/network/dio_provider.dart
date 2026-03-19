import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

final nasaApiDioProvider = Provider<Dio>((ref) {
  final dio = Dio(_baseOptions(AppConfig.nasaApiBaseUrl));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final shouldAttachApiKey =
            options.extra['attachApiKey'] as bool? ?? true;

        if (shouldAttachApiKey &&
            !options.queryParameters.containsKey('api_key')) {
          final query = Map<String, dynamic>.from(options.queryParameters);
          query['api_key'] = AppConfig.nasaApiKey;
          options.queryParameters = query;
        }

        handler.next(options);
      },
    ),
  );

  return dio;
});

final nasaMediaDioProvider = Provider<Dio>((ref) {
  return Dio(_baseOptions(AppConfig.nasaMediaBaseUrl));
});

BaseOptions _baseOptions(String baseUrl) {
  return BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    responseType: ResponseType.json,
    headers: const {'Accept': 'application/json'},
  );
}
