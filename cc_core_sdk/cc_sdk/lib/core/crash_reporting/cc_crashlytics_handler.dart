import 'package:catcher_2/model/platform_type.dart';
import 'package:catcher_2/model/report.dart';
import 'package:catcher_2/model/report_handler.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// A custom [ReportHandler] for Catcher2 that forwards errors to Firebase Crashlytics.
class CcCrashlyticsHandler extends ReportHandler {
  @override
  Future<bool> handle(Report report, _) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        report.error,
        report.stackTrace,
        reason: 'Caught by Catcher2',
        printDetails: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  List<PlatformType> getSupportedPlatforms() => [
    PlatformType.android,
    PlatformType.iOS,
  ];
}
