import '../../domain/entities/app_config_entity.dart';

/// Abstract class defining the contract for the AppConfig repository.
/// This should be implemented by the data layer.
abstract class AppConfigRepository {
  /// Gets the current app configuration.
  Future<AppConfigEntity> getConfig();

  /// Refreshes the app configuration from the remote source.
  Future<AppConfigEntity> refreshConfig();

  /// Gets a feature flag value by key.
  /// Returns [defaultValue] if the key doesn't exist.
  Future<T> getFeatureFlag<T>(String key, {required T defaultValue});

  /// Checks if an update is required for the given version.
  Future<bool> isUpdateRequired(String currentVersion);

  /// Gets the minimum required app version.
  Future<String> getMinimumRequiredVersion();
}
