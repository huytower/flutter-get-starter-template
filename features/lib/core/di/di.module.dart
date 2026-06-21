// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:cc_sdk/domain/services/cc_messaging_service.dart' as _i408;
import 'package:data/domain/repositories/auth/cc_auth_repository.dart' as _i475;
import 'package:data/domain/usecases/dashboard/get_dashboard_data_usecase.dart'
    as _i208;
import 'package:data/domain/usecases/dashboard/refresh_dashboard_data_usecase.dart'
    as _i393;
import 'package:data/domain/usecases/dashboard/update_dashboard_data_usecase.dart'
    as _i695;
import 'package:features/auth/biometric/data/datasources/local/cc_biometric_auth_datasource.dart'
    as _i820;
import 'package:features/auth/biometric/data/repositories/cc_biometric_auth_repository_impl.dart'
    as _i507;
import 'package:features/auth/biometric/domain/repositories/cc_biometric_auth_repository.dart'
    as _i85;
import 'package:features/auth/biometric/domain/usecases/cc_authenticate_with_biometrics.dart'
    as _i142;
import 'package:features/auth/biometric/presentation/bloc/biometric_bloc.dart'
    as _i18;
import 'package:features/core/di/di.dart' as _i674;
import 'package:features/features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i1003;
import 'package:features/features/auth/domain/usecases/login_anonymously_usecase.dart'
    as _i601;
import 'package:features/features/auth/domain/usecases/login_usecase.dart'
    as _i595;
import 'package:features/features/auth/domain/usecases/login_with_apple_usecase.dart'
    as _i307;
import 'package:features/features/auth/domain/usecases/login_with_google_usecase.dart'
    as _i600;
import 'package:features/features/auth/domain/usecases/logout_usecase.dart'
    as _i1043;
import 'package:features/features/auth/domain/usecases/sign_in_with_phone_number_usecase.dart'
    as _i602;
import 'package:features/features/auth/domain/usecases/verify_phone_number_usecase.dart'
    as _i55;
import 'package:features/features/auth/presentation/bloc/login_bloc.dart'
    as _i758;
import 'package:features/features/auth/presentation/bloc/phone_auth_bloc.dart'
    as _i586;
import 'package:features/features/counter/data/datasources/counter_local_data_source.dart'
    as _i19;
import 'package:features/features/counter/data/repositories/counter_repository_impl.dart'
    as _i345;
import 'package:features/features/counter/domain/repositories/counter_repository.dart'
    as _i112;
import 'package:features/features/counter/domain/usecases/decrement_counter_use_case.dart'
    as _i678;
import 'package:features/features/counter/domain/usecases/get_counter_use_case.dart'
    as _i476;
import 'package:features/features/counter/domain/usecases/increment_counter_use_case.dart'
    as _i827;
import 'package:features/features/counter/presentation/bloc/counter_bloc.dart'
    as _i8;
import 'package:features/features/dashboard/presentation/bloc/dashboard_bloc.dart'
    as _i1059;
import 'package:features/features/messaging/data/services/firebase_messaging_service_impl.dart'
    as _i827;
import 'package:features/features/web/presentation/cubit/web_cubit.dart'
    as _i312;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

class FeaturesPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final messagingModule = _$MessagingModule();
    gh.lazySingleton<_i820.CcBiometricAuthDatasource>(
        () => _i820.CcBiometricAuthDatasource());
    gh.lazySingleton<_i892.FirebaseMessaging>(
        () => messagingModule.firebaseMessaging);
    gh.lazySingleton<_i312.WebCubit>(() => _i312.WebCubit());
    gh.factory<_i1059.DashboardBloc>(() => _i1059.DashboardBloc(
          getDashboardDataUseCase: gh<_i208.GetDashboardDataUseCase>(),
          updateDashboardDataUseCase: gh<_i695.UpdateDashboardDataUseCase>(),
          refreshDashboardDataUseCase: gh<_i393.RefreshDashboardDataUseCase>(),
        ));
    gh.lazySingleton<_i1003.GetCurrentUserUseCase>(
        () => _i1003.GetCurrentUserUseCase(gh<_i475.CcAuthRepository>()));
    gh.lazySingleton<_i601.LoginAnonymouslyUseCase>(
        () => _i601.LoginAnonymouslyUseCase(gh<_i475.CcAuthRepository>()));
    gh.lazySingleton<_i595.LoginUseCase>(
        () => _i595.LoginUseCase(gh<_i475.CcAuthRepository>()));
    gh.lazySingleton<_i307.LoginWithAppleUseCase>(
        () => _i307.LoginWithAppleUseCase(gh<_i475.CcAuthRepository>()));
    gh.lazySingleton<_i600.LoginWithGoogleUseCase>(
        () => _i600.LoginWithGoogleUseCase(gh<_i475.CcAuthRepository>()));
    gh.lazySingleton<_i1043.LogoutUseCase>(
        () => _i1043.LogoutUseCase(gh<_i475.CcAuthRepository>()));
    gh.lazySingleton<_i602.SignInWithPhoneNumberUseCase>(
        () => _i602.SignInWithPhoneNumberUseCase(gh<_i475.CcAuthRepository>()));
    gh.lazySingleton<_i55.VerifyPhoneNumberUseCase>(
        () => _i55.VerifyPhoneNumberUseCase(gh<_i475.CcAuthRepository>()));
    gh.lazySingleton<_i85.CcBiometricAuthRepository>(() =>
        _i507.CcBiometricAuthRepositoryImpl(
            gh<_i820.CcBiometricAuthDatasource>()));
    gh.lazySingleton<_i408.CcMessagingService>(() =>
        _i827.FirebaseMessagingServiceImpl(gh<_i892.FirebaseMessaging>()));
    gh.factory<_i758.LoginBloc>(() => _i758.LoginBloc(
          gh<_i595.LoginUseCase>(),
          gh<_i600.LoginWithGoogleUseCase>(),
          gh<_i307.LoginWithAppleUseCase>(),
        ));
    gh.lazySingleton<_i19.CounterLocalDataSource>(() =>
        _i19.CounterLocalDataSourceImpl(
            sharedPreferences: gh<_i460.SharedPreferences>()));
    gh.factory<_i586.PhoneAuthBloc>(() => _i586.PhoneAuthBloc(
          gh<_i55.VerifyPhoneNumberUseCase>(),
          gh<_i602.SignInWithPhoneNumberUseCase>(),
        ));
    gh.lazySingleton<_i112.CounterRepository>(() => _i345.CounterRepositoryImpl(
        localDataSource: gh<_i19.CounterLocalDataSource>()));
    gh.lazySingleton<_i678.DecrementCounterUseCase>(
        () => _i678.DecrementCounterUseCase(gh<_i112.CounterRepository>()));
    gh.lazySingleton<_i476.GetCounterUseCase>(
        () => _i476.GetCounterUseCase(gh<_i112.CounterRepository>()));
    gh.lazySingleton<_i827.IncrementCounterUseCase>(
        () => _i827.IncrementCounterUseCase(gh<_i112.CounterRepository>()));
    gh.lazySingleton<_i142.CcAuthenticateWithBiometrics>(() =>
        _i142.CcAuthenticateWithBiometrics(
            gh<_i85.CcBiometricAuthRepository>()));
    gh.factory<_i18.BiometricBloc>(() => _i18.BiometricBloc(
          gh<_i142.CcAuthenticateWithBiometrics>(),
          gh<_i85.CcBiometricAuthRepository>(),
        ));
    gh.factory<_i8.CounterBloc>(() => _i8.CounterBloc(
          getCounterUseCase: gh<_i476.GetCounterUseCase>(),
          incrementCounterUseCase: gh<_i827.IncrementCounterUseCase>(),
          decrementCounterUseCase: gh<_i678.DecrementCounterUseCase>(),
        ));
  }
}

class _$MessagingModule extends _i674.MessagingModule {}
