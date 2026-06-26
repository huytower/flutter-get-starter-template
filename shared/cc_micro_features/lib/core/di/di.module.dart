// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:cc_bridge/export_cc_bridge.dart' as _i727;
import 'package:cc_micro_features/core/di/di.dart' as _i407;
import 'package:cc_micro_features/features/auth/data/repositories/firebase_auth_repository_impl.dart'
    as _i832;
import 'package:cc_micro_features/features/auth/domain/repositories/firebase_auth_repository.dart'
    as _i745;
import 'package:cc_micro_features/features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i380;
import 'package:cc_micro_features/features/auth/domain/usecases/login_anonymously_usecase.dart'
    as _i566;
import 'package:cc_micro_features/features/auth/domain/usecases/login_usecase.dart'
    as _i23;
import 'package:cc_micro_features/features/auth/domain/usecases/login_with_apple_usecase.dart'
    as _i632;
import 'package:cc_micro_features/features/auth/domain/usecases/login_with_google_usecase.dart'
    as _i811;
import 'package:cc_micro_features/features/auth/domain/usecases/logout_usecase.dart'
    as _i732;
import 'package:cc_micro_features/features/auth/domain/usecases/sign_in_with_phone_number_usecase.dart'
    as _i189;
import 'package:cc_micro_features/features/auth/domain/usecases/verify_phone_number_usecase.dart'
    as _i120;
import 'package:cc_micro_features/features/auth/presentation/bloc/login_bloc.dart'
    as _i345;
import 'package:cc_micro_features/features/auth/presentation/bloc/phone_auth_bloc.dart'
    as _i902;
import 'package:cc_micro_features/features/auth/presentation/session/session_provider_impl.dart'
    as _i638;
import 'package:cc_micro_features/features/biometric/data/datasources/biometric_local_data_source.dart'
    as _i350;
import 'package:cc_micro_features/features/biometric/data/repositories/biometric_repository_impl.dart'
    as _i32;
import 'package:cc_micro_features/features/biometric/domain/repositories/biometric_repository.dart'
    as _i521;
import 'package:cc_micro_features/features/biometric/domain/usecases/authenticate_with_biometrics_usecase.dart'
    as _i721;
import 'package:cc_micro_features/features/biometric/presentation/bloc/biometric_bloc.dart'
    as _i384;
import 'package:cc_micro_features/features/messaging/data/services/firebase_messaging_service_impl.dart'
    as _i441;
import 'package:cc_micro_features/features/web/presentation/cubit/web_cubit.dart'
    as _i354;
import 'package:cc_sdk/domain/services/cc_messaging_service.dart' as _i408;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;

class CcMicroFeaturesPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final messagingModule = _$MessagingModule();
    gh.lazySingleton<_i892.FirebaseMessaging>(
      () => messagingModule.firebaseMessaging,
    );
    gh.lazySingleton<_i350.BiometricLocalDataSource>(
      () => _i350.BiometricLocalDataSource(),
    );
    gh.lazySingleton<_i354.WebCubit>(() => _i354.WebCubit());
    gh.lazySingleton<_i521.BiometricRepository>(
      () => _i32.BiometricRepositoryImpl(gh<_i350.BiometricLocalDataSource>()),
    );
    gh.lazySingleton<_i745.FirebaseAuthRepository>(
      () => _i832.FirebaseAuthRepositoryImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.lazySingleton<_i408.CcMessagingService>(
      () => _i441.FirebaseMessagingServiceImpl(gh<_i892.FirebaseMessaging>()),
    );
    gh.lazySingleton<_i380.GetCurrentUserUseCase>(
      () => _i380.GetCurrentUserUseCase(gh<_i745.FirebaseAuthRepository>()),
    );
    gh.lazySingleton<_i566.LoginAnonymouslyUseCase>(
      () => _i566.LoginAnonymouslyUseCase(gh<_i745.FirebaseAuthRepository>()),
    );
    gh.lazySingleton<_i23.LoginUseCase>(
      () => _i23.LoginUseCase(gh<_i745.FirebaseAuthRepository>()),
    );
    gh.lazySingleton<_i632.LoginWithAppleUseCase>(
      () => _i632.LoginWithAppleUseCase(gh<_i745.FirebaseAuthRepository>()),
    );
    gh.lazySingleton<_i811.LoginWithGoogleUseCase>(
      () => _i811.LoginWithGoogleUseCase(gh<_i745.FirebaseAuthRepository>()),
    );
    gh.lazySingleton<_i732.LogoutUseCase>(
      () => _i732.LogoutUseCase(gh<_i745.FirebaseAuthRepository>()),
    );
    gh.lazySingleton<_i189.SignInWithPhoneNumberUseCase>(
      () => _i189.SignInWithPhoneNumberUseCase(
        gh<_i745.FirebaseAuthRepository>(),
      ),
    );
    gh.lazySingleton<_i120.VerifyPhoneNumberUseCase>(
      () => _i120.VerifyPhoneNumberUseCase(gh<_i745.FirebaseAuthRepository>()),
    );
    gh.factory<_i345.LoginBloc>(
      () => _i345.LoginBloc(
        gh<_i23.LoginUseCase>(),
        gh<_i811.LoginWithGoogleUseCase>(),
        gh<_i632.LoginWithAppleUseCase>(),
      ),
    );
    gh.factory<_i902.PhoneAuthBloc>(
      () => _i902.PhoneAuthBloc(
        gh<_i120.VerifyPhoneNumberUseCase>(),
        gh<_i189.SignInWithPhoneNumberUseCase>(),
      ),
    );
    gh.lazySingleton<_i721.AuthenticateWithBiometricsUseCase>(
      () => _i721.AuthenticateWithBiometricsUseCase(
        gh<_i521.BiometricRepository>(),
      ),
    );
    gh.lazySingleton<_i727.SessionContract>(
      () => _i638.SessionProviderImpl(
        gh<_i380.GetCurrentUserUseCase>(),
        gh<_i732.LogoutUseCase>(),
      ),
    );
    gh.factory<_i384.BiometricBloc>(
      () => _i384.BiometricBloc(
        gh<_i721.AuthenticateWithBiometricsUseCase>(),
        gh<_i521.BiometricRepository>(),
      ),
    );
  }
}

class _$MessagingModule extends _i407.MessagingModule {}
