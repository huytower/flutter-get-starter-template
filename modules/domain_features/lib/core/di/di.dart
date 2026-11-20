import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    SessionContract,
    AuthCoordinator,
    CcDeviceInfoHelper,
    InternetConnection,
  ],
)
void initMicroPackage() {}
