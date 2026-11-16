import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/app_update_config_entity.dart';

/// Where the update policy comes from. Implemented by the host app (App Shell
/// or `data_config`) and registered in DI, so this feature stays project-blind
/// and never reads env keys or remote config itself.
abstract class AppUpdateConfigRepository {
  Future<Result<AppUpdateConfigEntity, CcFailure>> getConfig();
}
