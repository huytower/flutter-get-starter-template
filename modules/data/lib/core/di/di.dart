import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

/// Configures dependency injection for the data module.
/// Uses the Micro-Package pattern for injectable.
@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    CcAppStorage,
    Dio,
    InternetConnection,
    SharedPreferences,
    FirebaseAuth,
    GoogleSignIn,
  ],
)
void initMicroPackage() {}

@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn();
}
