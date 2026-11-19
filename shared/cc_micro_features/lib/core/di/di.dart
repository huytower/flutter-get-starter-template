import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/app_update/domain/repositories/app_update_config_repository.dart';

final GetIt getIt = GetIt.instance;

/// Configures dependency injection for the cc_micro_features library.
/// Uses the Micro-Package pattern for injectable.
@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    SharedPreferences,
    // Implemented by the host app (env / remote config), see app_update.
    AppUpdateConfigRepository,
    CcDeviceInfoHelper,
    CcDeviceEntity,
    FirebaseAuth,
    GoogleSignIn,
  ],
)
void initMicroPackage() {}

// Shared services like FirebaseAuth and GoogleSignIn are provided by modules/data
// to avoid GetIt duplication errors in the Super App orchestrator.

@module
abstract class MessagingModule {
  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;
}
