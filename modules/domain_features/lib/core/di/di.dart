import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/contracts/user_level_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit.microPackage(
  // Implemented in modules/bridge (registered after this package).
  ignoreUnregisteredTypes: [
    FinancialRefreshProvider,
    GuidelineProvider,
    UserLevelProvider,
    SessionContract,
    AuthCoordinator,
    CcDeviceInfoHelper,
    InternetConnection,
  ],
)
void initMicroPackage() {}
