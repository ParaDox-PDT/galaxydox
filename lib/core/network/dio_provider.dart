import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

const String _retryAttemptKey = 'retryAttempt';
const int _maxRetryAttempts = 2;

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
      onError: (error, handler) async {
        final options = error.requestOptions;
        final retryAttempt = options.extra[_retryAttemptKey] as int? ?? 0;

        if (_shouldRetry(error) && retryAttempt < _maxRetryAttempts) {
          options.extra[_retryAttemptKey] = retryAttempt + 1;
          final retryDelay = Duration(milliseconds: 350 * (retryAttempt + 1));

          await Future<void>.delayed(retryDelay);

          try {
            final response = await dio.fetch<dynamic>(options);
            handler.resolve(response);
            return;
          } on DioException catch (retryError) {
            handler.next(retryError);
            return;
          }
        }

        handler.next(error);
      },
    ),
  );

  return dio;
}

bool _shouldRetry(DioException error) {
  final method = error.requestOptions.method.toUpperCase();
  final statusCode = error.response?.statusCode;

  if (method != 'GET') {
    return false;
  }

  if (statusCode != null && statusCode >= 500) {
    return true;
  }

  return error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.unknown;
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
