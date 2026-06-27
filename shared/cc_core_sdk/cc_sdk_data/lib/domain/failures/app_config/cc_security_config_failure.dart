part of 'cc_app_config_failure.dart';

/// Thrown or returned when there's a security-related configuration issue.
class CcSecurityConfigFailure extends CcAppConfigFailure {
  /// The security rule that was violated.
  final String securityRule;

  /// The severity level of the security issue.
  final String severity;

  const CcSecurityConfigFailure(
    super.message, {
    required String key,
    required this.securityRule,
    this.severity = 'high',
    String type = 'CcSecurityConfigFailure',
  }) : super(key: key, type: type);

  @override
  List<Object?> get props => [...super.props, securityRule, severity];

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'securityRule': securityRule,
    'severity': severity,
  };

  /// Creates a security failure for sensitive data exposure.
  factory CcSecurityConfigFailure.sensitiveDataExposure({
    required String key,
    String? message,
  }) => CcSecurityConfigFailure(
    message ?? 'Sensitive data exposure detected in configuration',
    key: key,
    securityRule: 'sensitive_data_exposure',
    severity: 'critical',
  );

  /// Creates a security failure for insufficient permissions.
  factory CcSecurityConfigFailure.insufficientPermissions({
    required String key,
    required String requiredPermission,
  }) => CcSecurityConfigFailure(
    'Insufficient permissions to access configuration. Required: $requiredPermission',
    key: key,
    securityRule: 'insufficient_permissions',
    severity: 'error',
  );
}
