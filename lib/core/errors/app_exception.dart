import 'package:dio/dio.dart';

enum AppExceptionType {
  network,
  timeout,
  unauthorized,
  serialization,
  storage,
  unknown,
}

class AppException implements Exception {
  const AppException({required this.type, required this.message, this.cause});

  final AppExceptionType type;
  final String message;
  final Object? cause;

  @override
  String toString() => 'AppException(type: $type, message: $message)';
}

AppException mapNasaStatusException({
  required int? statusCode,
  required String resource,
  Object? cause,
}) {
  if (statusCode == 401 || statusCode == 403) {
    return AppException(
      type: AppExceptionType.unauthorized,
      message: 'NASA API key is invalid or unauthorized.',
      cause: cause,
    );
  }

  if (statusCode != null && statusCode >= 500) {
    return AppException(
      type: AppExceptionType.network,
      message:
          'NASA services are temporarily unavailable while loading $resource.',
      cause: cause,
    );
  }

  return AppException(
    type: AppExceptionType.network,
    message: 'NASA returned status $statusCode while loading $resource.',
    cause: cause,
  );
}

AppException mapNasaDioException({
  required DioException error,
  required String resource,
  required String timeoutMessage,
  String? networkMessage,
}) {
  final statusCode = error.response?.statusCode;

  if (statusCode != null) {
    return mapNasaStatusException(
      statusCode: statusCode,
      resource: resource,
      cause: error,
    );
  }

  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return AppException(
      type: AppExceptionType.timeout,
      message: timeoutMessage,
      cause: error,
    );
  }

  return AppException(
    type: AppExceptionType.network,
    message:
        networkMessage ??
        'Unable to reach NASA while loading $resource. Please try again.',
    cause: error,
  );
}
