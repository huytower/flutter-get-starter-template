import 'dart:async';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../../domain/entities/biometric_auth_type_entity.dart';

/// Data source for handling local biometric authentication
@lazySingleton
class BiometricLocalDataSource {
  final LocalAuthentication _auth;
  bool _canAuthenticate = false;

  /// Error code constants (matching local_auth package)
  static const String notAvailable = 'NotAvailable';
  static const String notEnrolled = 'NotEnrolled';
  static const String lockedOut = 'LockedOut';
  static const String permanentlyLockedOut = 'PermanentlyLockedOut';
  static const String passcodeNotSet = 'PasscodeNotSet';
  static const String userCanceled = 'UserCanceled';
  static const String appCanceled = 'AppCanceled';
  static const String systemCanceled = 'SystemCanceled';

  /// Get the current authentication status
  bool get canAuthenticate => _canAuthenticate;

  BiometricLocalDataSource() : _auth = LocalAuthentication();

  /// Initialize the biometric authentication
  Future<void> initialize() async {
    try {
      _canAuthenticate =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } on PlatformException catch (e) {
      el
          .tr(
            CcLocaleKeys.auth_biometric_error_generic,
            namedArgs: {'error': e.message ?? ''},
          )
          .Log();
      _canAuthenticate = false;
    }
  }

  /// Check if biometric authentication is available and enrolled
  Future<bool> isBiometricAvailable() async {
    try {
      return await _auth.canCheckBiometrics &&
          await _auth.isDeviceSupported() &&
          (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricAuthTypeEntity>> getAvailableBiometrics() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      return biometrics.map((type) {
        switch (type) {
          case BiometricType.face:
            return BiometricAuthTypeEntity.face;
          case BiometricType.fingerprint:
            return BiometricAuthTypeEntity.fingerprint;
          default:
            return BiometricAuthTypeEntity.none;
        }
      }).toList();
    } on PlatformException {
      return [BiometricAuthTypeEntity.none];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    required String localizedReason,
    String? androidSignInTitle,
    String? cancelButtonText,
    bool biometricOnly = true,
    bool sensitiveTransaction = false,
  }) async {
    if (!_canAuthenticate) {
      el.tr(CcLocaleKeys.auth_biometric_error_not_available).Log();
      return false;
    }

    try {
      final result = await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: biometricOnly,
        sensitiveTransaction: sensitiveTransaction,
        authMessages: [
          AndroidAuthMessages(
            signInTitle:
                androidSignInTitle ?? el.tr(CcLocaleKeys.auth_biometric_reason),
            cancelButton: cancelButtonText ?? el.tr(CcLocaleKeys.common_cancel),
          ),
          IOSAuthMessages(
            cancelButton: cancelButtonText ?? el.tr(CcLocaleKeys.common_cancel),
            localizedFallbackTitle: el.tr(CcLocaleKeys.auth_biometric_fallback),
          ),
        ],
      );

      return result;
    } on PlatformException catch (e) {
      _handleBiometricError(e);
      return false;
    }
  }

  /// Handle different biometric authentication errors
  void _handleBiometricError(PlatformException e) {
    switch (e.code) {
      case notAvailable:
        el.tr(CcLocaleKeys.auth_biometric_error_not_available).Log();
        break;
      case notEnrolled:
        el.tr(CcLocaleKeys.auth_biometric_error_not_enrolled).Log();
        break;
      case lockedOut:
        el.tr(CcLocaleKeys.auth_biometric_error_locked_out).Log();
        break;
      case permanentlyLockedOut:
        el.tr(CcLocaleKeys.auth_biometric_error_permanently_locked_out).Log();
        break;
      case passcodeNotSet:
        el.tr(CcLocaleKeys.auth_biometric_error_passcode_not_set).Log();
        break;
      case userCanceled:
        el.tr(CcLocaleKeys.auth_biometric_error_user_canceled).Log();
        break;
      case appCanceled:
        el.tr(CcLocaleKeys.auth_biometric_error_app_canceled).Log();
        break;
      case systemCanceled:
        el.tr(CcLocaleKeys.auth_biometric_error_system_canceled).Log();
        break;
      default:
        el
            .tr(
              CcLocaleKeys.auth_biometric_error_generic,
              namedArgs: {'error': e.message ?? ''},
            )
            .Log();
        break;
    }
  }
}
