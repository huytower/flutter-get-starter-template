import 'package:equatable/equatable.dart';

/// Represents the application configuration entity in the domain layer.
class AppConfigEntity extends Equatable {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String environment;
  final Map<String, dynamic> featureFlags;

  const AppConfigEntity({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.environment,
    this.featureFlags = const {},
  });

  /// Creates a copy of this entity with the given fields replaced with the new values.
  AppConfigEntity copyWith({
    String? appName,
    String? packageName,
    String? version,
    String? buildNumber,
    String? environment,
    Map<String, dynamic>? featureFlags,
  }) {
    return AppConfigEntity(
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      environment: environment ?? this.environment,
      featureFlags: featureFlags ?? this.featureFlags,
    );
  }

  @override
  List<Object?> get props => [
    appName,
    packageName,
    version,
    buildNumber,
    environment,
    featureFlags,
  ];
}
