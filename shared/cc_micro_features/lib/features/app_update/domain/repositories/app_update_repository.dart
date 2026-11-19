import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/installed_app_entity.dart';

/// Device-side operations of the update flow (implemented in this feature).
abstract class AppUpdateRepository {
  /// Version and identity of the installed app.
  Future<Result<InstalledAppEntity, CcFailure>> getInstalledApp();

  /// Opens this app's page in the Play Store / App Store.
  Future<Result<Unit, CcFailure>> openStore({
    String? iosAppStoreId,
    String? androidPackageName,
  });
}
