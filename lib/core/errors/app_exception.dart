enum AppExceptionType { network, timeout, unauthorized, serialization, unknown }

class AppException implements Exception {
  const AppException({required this.type, required this.message, this.cause});

  final AppExceptionType type;
  final String message;
  final Object? cause;

  @override
  String toString() => 'AppException(type: $type, message: $message)';
}
