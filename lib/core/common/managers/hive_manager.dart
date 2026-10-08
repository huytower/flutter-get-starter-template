import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

/// Manages Hive database operations
@lazySingleton
class HiveManager {
  /// Closes all Hive boxes
  @disposeMethod
  Future<void> closeBoxes() async {
    final boxNames = [
      CcHiveBox.APP_BOX_NAME,
      CcHiveBox.DEVICE_BOX_NAME,
      CcHiveBox.TRACK_LOG_BOX_NAME,
      CcHiveBox.EXCHANGE_RATE_BOX_NAME,
    ];

    final closeFutures = boxNames
        .where((name) => Hive.isBoxOpen(name))
        .map((name) => Hive.box(name).close());

    await Future.wait(closeFutures);
  }
}
