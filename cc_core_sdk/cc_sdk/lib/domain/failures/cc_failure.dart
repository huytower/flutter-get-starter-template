import 'package:equatable/equatable.dart';

/// Base class for all Business Failures in the Domain layer.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure(String message, {int? statusCode})
    : super(message, statusCode: statusCode);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class BiometricFailure extends Failure {
  const BiometricFailure(String message) : super(message);
}

class DeviceFailure extends Failure {
  const DeviceFailure(String message) : super(message);
}

class CurlFailure extends Failure {
  final String? responseBody;

  const CurlFailure(String message, {this.responseBody}) : super(message);

  @override
  List<Object?> get props => [message, responseBody];
}
