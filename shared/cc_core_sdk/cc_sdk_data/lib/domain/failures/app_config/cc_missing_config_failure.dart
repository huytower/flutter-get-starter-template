part of '../../../../../cc_sdk_data/lib/domain/failures/app_config/cc_app_config_failure.dart';

/// Thrown or returned when a required configuration value is missing.
class CcMissingConfigFailure extends CcAppConfigFailure {
  const CcMissingConfigFailure(
    String key, {
    String? message,
    String type = 'CcMissingConfigFailure',
  }) : super(
         message ?? 'Missing required configuration: $key',
         key: key,
         type: type,
       );
}
