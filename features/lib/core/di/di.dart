import 'package:cc_sdk/core/helper/cc_device_info_helper.dart';
import 'package:cc_sdk/domain/entities/cc_device_entity.dart';
import 'package:data/domain/repositories/auth/cc_auth_repository.dart';
import 'package:data/domain/usecases/dashboard/get_dashboard_data_usecase.dart';
import 'package:data/domain/usecases/dashboard/refresh_dashboard_data_usecase.dart';
import 'package:data/domain/usecases/dashboard/update_dashboard_data_usecase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

/// Configures dependency injection for the features library.
/// Uses the Micro-Package pattern for injectable.
@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    SharedPreferences,
    GetDashboardDataUseCase,
    UpdateDashboardDataUseCase,
    RefreshDashboardDataUseCase,
    CcDeviceInfoHelper,
    CcDeviceEntity,
    CcAuthRepository,
    FirebaseMessaging,
  ],
)
void initMicroPackage() {}

@module
abstract class MessagingModule {
  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;
}
