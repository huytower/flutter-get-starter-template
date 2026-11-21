import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_micro_features/features/auth/domain/repositories/auth_repository.dart';
import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/contracts/user_level_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:theme/presentation/provider/theme_provider.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit.microPackage(
  // Implemented in modules/bridge (registered after this package).
  ignoreUnregisteredTypes: [
    FinancialRefreshProvider,
    GuidelineProvider,
    UserLevelProvider,
    SessionContract,
    AuthRepository,
    AuthCoordinator,
    CcDeviceInfoHelper,
    InternetConnection,
    CcAnalytics,
    CcAiClient,
    CcLocationService,
    CcSpeechRecognizer,
    // Registered by the App Shell (lib/core/di/module/dependencies.dart).
    ThemeProvider,
  ],
)
void initMicroPackage() {}
