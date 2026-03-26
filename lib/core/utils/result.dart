// Erreurs génériques
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException({required super.message, super.code});
}

class NetworkException extends AppException {
  NetworkException({required super.message, super.code});
}

class CacheException extends AppException {
  CacheException({required super.message, super.code});
}

class AuthException extends AppException {
  AuthException({required super.message, super.code});
}

class ValidationException extends AppException {
  ValidationException({required super.message, super.code});
}

// Success/Failure Result
abstract class Result<T> {
  const Result();

  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess);

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure;
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) =>
      onSuccess(data);
}

class Failure extends Result<dynamic> {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  R fold<R>(R Function(Failure) onFailure, R Function(dynamic) onSuccess) =>
      onFailure(this);
}
