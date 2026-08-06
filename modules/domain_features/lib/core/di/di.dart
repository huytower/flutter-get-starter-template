import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    FirestoreSyncService,
    SessionContract,
    AuthCoordinator,
    CcDeviceInfoHelper,
    InternetConnection,
  ],
)
void initMicroPackage() {}
