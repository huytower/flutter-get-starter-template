import 'package:injectable/injectable.dart';

import '../../../data/datasources/local/box/app_storage/prj_app_storage.dart';
import '../../../data/datasources/local/box/device_info/prj_device_info.dart';

/// Registers third-party/static-instance dependencies that cannot be
/// auto-registered (they use static .instance patterns).
@module
abstract class AppConfigDependencies {
  @lazySingleton
  PrjAppStorage get ccAppStorage => PrjAppStorage.instance;

  @lazySingleton
  PrjDeviceInfo get ccDeviceInfo => PrjDeviceInfo.instance;
}
