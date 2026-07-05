import 'package:equatable/equatable.dart';

/// Base class for all Business Failures in the Domain layer.
abstract class CcFailure extends Equatable {
  final String message;
  final int? statusCode;

  const CcFailure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends CcFailure {
  const ServerFailure(String message, {int? statusCode})
    : super(message, statusCode: statusCode);
}

class CacheFailure extends CcFailure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends CcFailure {
  const NetworkFailure(String message) : super(message);
}

class BiometricFailure extends CcFailure {
  const BiometricFailure(String message) : super(message);
}

class DeviceFailure extends CcFailure {
  const DeviceFailure(String message) : super(message);
}

class UnauthorizedFailure extends CcFailure {
  const UnauthorizedFailure(String message) : super(message);
}

class UnknownFailure extends CcFailure {
  const UnknownFailure(String message) : super(message);
}

/// Raised when domain-level input validation fails (e.g. empty name,
/// non-positive amount, invalid date range).
class ValidationFailure extends CcFailure {
  const ValidationFailure(String message) : super(message);
}

class CurlFailure extends CcFailure {
  final String? responseBody;

  const CurlFailure(String message, {this.responseBody}) : super(message);

  @override
  List<Object?> get props => [message, responseBody];
}
