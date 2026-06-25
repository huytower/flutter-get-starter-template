import 'package:cc_sdk/core/helper/cc_device_info_helper.dart';
import 'package:cc_sdk/domain/entities/cc_device_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

/// Configures dependency injection for the micro_features library.
/// Uses the Micro-Package pattern for injectable.
@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    SharedPreferences,
    CcDeviceInfoHelper,
    CcDeviceEntity,
    FirebaseMessaging,
  ],
)
void initMicroPackage() {}

@module
abstract class MessagingModule {
  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;
}

@module
abstract class AuthModule {
  @lazySingleton
  firebase_auth.FirebaseAuth get firebaseAuth =>
      firebase_auth.FirebaseAuth.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn.instance;
}
