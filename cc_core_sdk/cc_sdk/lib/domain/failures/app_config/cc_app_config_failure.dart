import 'package:meta/meta.dart';

import '../cc_failure.dart';

part 'cc_invalid_config_failure.dart';
part 'cc_missing_config_failure.dart';
part 'cc_security_config_failure.dart';

/// Base failure class for configuration-related errors.
///
/// This class extends [CcFailure] and uses modern Dart 3 sealed class features
/// to allow for exhaustive pattern matching.
@immutable
sealed class CcAppConfigFailure extends CcFailure {
  /// The configuration key associated with this error, if any.
  final String? key;

  /// The type of the failure for programmatic handling.
  final String type;

  const CcAppConfigFailure(
    super.message, {
    this.key,
    this.type = 'CcAppConfigFailure',
    super.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode, key, type];

  /// Converts the failure to a JSON-serializable map.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'key': key,
      if (statusCode != null) 'statusCode': statusCode,
    };
  }

  @override
  String toString() => '$type: $message${key != null ? ' (key: $key)' : ''}';
}

/// Generic configuration failure when a more specific type isn't available.
class CcConfigFailure extends CcAppConfigFailure {
  const CcConfigFailure(
    super.message, {
    super.key,
    super.type = 'CcConfigFailure',
    super.statusCode,
  });
}
