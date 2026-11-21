import 'package:app_config/core/config/app/prj_env.dart';
import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_firebase/export_cc_sdk_firebase.dart';
import 'package:cc_sdk_slack/export_cc_sdk_slack.dart';
import 'package:injectable/injectable.dart';
import 'package:theme/presentation/provider/theme_provider.dart';

/// Provides app-level dependencies built from external packages.
@module
abstract class Dependencies {
  /// Single [ThemeProvider] instance shared across all routing strategies.
  @lazySingleton
  ThemeProvider provideThemeProvider() =>
      ThemeProvider(initialDarkMode: CcAppStorage.instance.isDarkMode);

  /// User feedback goes to the team's Slack channel. To send it through a
  /// backend instead, return another [CcFeedbackReporter] here.
  @lazySingleton
  CcFeedbackReporter provideFeedbackReporter() =>
      CcSlackFeedbackReporter(webhookUrl: PrjEnv.slackFeedbackWebhookUrl);

  /// Errors go to Crashlytics and to the team's #crash Slack channel, in every
  /// build mode: uncaught ones through Catcher2's `CcCrashReporterHandler`,
  /// caught ones through `recordError` (e.g. `CcBaseRepository.safeRequest`).
  @lazySingleton
  CcCrashReporter provideCrashReporter(
    CcFirebaseCrashReporter crashlytics,
    CcDeviceInfoHelper deviceInfo,
    CcAppAttestation attestation,
  ) => CcCompositeCrashReporter([
    crashlytics,
    CcSlackCrashReporter(
      webhookUrl: PrjEnv.slackCrashWebhookUrl,
      deviceInfo: deviceInfo,
      attestation: attestation,
    ),
  ]);
}
