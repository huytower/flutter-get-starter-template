// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:cc_bridge/export_cc_bridge.dart' as _i727;
import 'package:cc_sdk/domain/services/cc_messaging_service.dart' as _i408;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:micro_features/core/di/di.dart' as _i1043;
import 'package:micro_features/features/auth/data/repositories/firebase_auth_repository_impl.dart'
    as _i781;
import 'package:micro_features/features/auth/domain/repositories/firebase_auth_repository.dart'
    as _i597;
import 'package:micro_features/features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i396;
import 'package:micro_features/features/auth/domain/usecases/login_anonymously_usecase.dart'
    as _i468;
import 'package:micro_features/features/auth/domain/usecases/login_usecase.dart'
    as _i400;
import 'package:micro_features/features/auth/domain/usecases/login_with_apple_usecase.dart'
    as _i146;
import 'package:micro_features/features/auth/domain/usecases/login_with_google_usecase.dart'
    as _i1034;
import 'package:micro_features/features/auth/domain/usecases/logout_usecase.dart'
    as _i779;
import 'package:micro_features/features/auth/domain/usecases/sign_in_with_phone_number_usecase.dart'
    as _i970;
import 'package:micro_features/features/auth/domain/usecases/verify_phone_number_usecase.dart'
    as _i801;
import 'package:micro_features/features/auth/presentation/bloc/login_bloc.dart'
    as _i788;
import 'package:micro_features/features/auth/presentation/bloc/phone_auth_bloc.dart'
    as _i854;
import 'package:micro_features/features/auth/presentation/session/session_provider_impl.dart'
    as _i158;
import 'package:micro_features/features/biometric/data/datasources/biometric_local_data_source.dart'
    as _i22;
import 'package:micro_features/features/biometric/data/repositories/biometric_repository_impl.dart'
    as _i817;
import 'package:micro_features/features/biometric/domain/repositories/biometric_repository.dart'
    as _i359;
import 'package:micro_features/features/biometric/domain/usecases/authenticate_with_biometrics_usecase.dart'
    as _i55;
import 'package:micro_features/features/biometric/presentation/bloc/biometric_bloc.dart'
    as _i992;
import 'package:micro_features/features/messaging/data/services/firebase_messaging_service_impl.dart'
    as _i371;
import 'package:micro_features/features/web/presentation/cubit/web_cubit.dart'
    as _i149;

class MicroFeaturesPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final messagingModule = _$MessagingModule();
    final authModule = _$AuthModule();
    gh.lazySingleton<_i892.FirebaseMessaging>(
        () => messagingModule.firebaseMessaging);
    gh.lazySingleton<_i59.FirebaseAuth>(() => authModule.firebaseAuth);
    gh.lazySingleton<_i116.GoogleSignIn>(() => authModule.googleSignIn);
    gh.lazySingleton<_i22.BiometricLocalDataSource>(
        () => _i22.BiometricLocalDataSource());
    gh.lazySingleton<_i149.WebCubit>(() => _i149.WebCubit());
    gh.lazySingleton<_i359.BiometricRepository>(() =>
        _i817.BiometricRepositoryImpl(gh<_i22.BiometricLocalDataSource>()));
    gh.lazySingleton<_i408.CcMessagingService>(() =>
        _i371.FirebaseMessagingServiceImpl(gh<_i892.FirebaseMessaging>()));
    gh.lazySingleton<_i597.FirebaseAuthRepository>(
        () => _i781.FirebaseAuthRepositoryImpl(
              gh<_i59.FirebaseAuth>(),
              gh<_i116.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i55.AuthenticateWithBiometricsUseCase>(() =>
        _i55.AuthenticateWithBiometricsUseCase(
            gh<_i359.BiometricRepository>()));
    gh.lazySingleton<_i396.GetCurrentUserUseCase>(
        () => _i396.GetCurrentUserUseCase(gh<_i597.FirebaseAuthRepository>()));
    gh.lazySingleton<_i468.LoginAnonymouslyUseCase>(() =>
        _i468.LoginAnonymouslyUseCase(gh<_i597.FirebaseAuthRepository>()));
    gh.lazySingleton<_i400.LoginUseCase>(
        () => _i400.LoginUseCase(gh<_i597.FirebaseAuthRepository>()));
    gh.lazySingleton<_i146.LoginWithAppleUseCase>(
        () => _i146.LoginWithAppleUseCase(gh<_i597.FirebaseAuthRepository>()));
    gh.lazySingleton<_i1034.LoginWithGoogleUseCase>(() =>
        _i1034.LoginWithGoogleUseCase(gh<_i597.FirebaseAuthRepository>()));
    gh.lazySingleton<_i779.LogoutUseCase>(
        () => _i779.LogoutUseCase(gh<_i597.FirebaseAuthRepository>()));
    gh.lazySingleton<_i970.SignInWithPhoneNumberUseCase>(() =>
        _i970.SignInWithPhoneNumberUseCase(gh<_i597.FirebaseAuthRepository>()));
    gh.lazySingleton<_i801.VerifyPhoneNumberUseCase>(() =>
        _i801.VerifyPhoneNumberUseCase(gh<_i597.FirebaseAuthRepository>()));
    gh.factory<_i854.PhoneAuthBloc>(() => _i854.PhoneAuthBloc(
          gh<_i801.VerifyPhoneNumberUseCase>(),
          gh<_i970.SignInWithPhoneNumberUseCase>(),
        ));
    gh.lazySingleton<_i727.SessionContract>(() => _i158.SessionProviderImpl(
          gh<_i396.GetCurrentUserUseCase>(),
          gh<_i779.LogoutUseCase>(),
        ));
    gh.factory<_i992.BiometricBloc>(() => _i992.BiometricBloc(
          gh<_i55.AuthenticateWithBiometricsUseCase>(),
          gh<_i359.BiometricRepository>(),
        ));
    gh.factory<_i788.LoginBloc>(() => _i788.LoginBloc(
          gh<_i400.LoginUseCase>(),
          gh<_i1034.LoginWithGoogleUseCase>(),
          gh<_i146.LoginWithAppleUseCase>(),
        ));
  }
}

class _$MessagingModule extends _i1043.MessagingModule {}

class _$AuthModule extends _i1043.AuthModule {}
