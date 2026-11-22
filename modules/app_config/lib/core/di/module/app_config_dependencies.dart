import 'package:injectable/injectable.dart';

import '../../../data/datasource/local/box/app_storage/cc_app_storage.dart';
import '../../../data/datasource/local/box/device_info/cc_device_info.dart';

/// Registers third-party/static-instance dependencies that cannot be
/// auto-registered (they use static .instance patterns).
@module
abstract class AppConfigDependencies {
  @lazySingleton
  CcAppStorage get ccAppStorage => CcAppStorage.instance;

  @lazySingleton
  CcDeviceInfo get ccDeviceInfo => CcDeviceInfo.instance;
}
