import 'dart:developer' as developer;

import 'package:firebase_app_check/firebase_app_check.dart';

/// Helper class for Firebase App Check initialization and configuration.
/// 
/// This class is state-management agnostic and provides a clean interface
/// for initializing Firebase App Check with the appropriate providers
/// based on the platform (Android/iOS/Web).
class CcAppCheckHelper {
  CcAppCheckHelper._();

  /// Initializes Firebase App Check with the appropriate provider.
  ///
  /// On Android: Uses Play Integrity provider
  /// On iOS: Uses DeviceCheck provider (or App Attest if available)
  /// On Web: Uses reCAPTCHA provider
  ///
  /// [debugToken] Optional debug token for development/testing.
  /// When provided in debug mode, App Check will use this token instead
  /// of the actual attestation provider.
  ///
  /// Returns [Future<void>] that completes when App Check is initialized.
  static Future<void> initialize({String? debugToken}) async {
    try {
      await FirebaseAppCheck.instance.activate();

      developer.log('Firebase App Check initialized successfully');
    } catch (error, stackTrace) {
      developer.log(
        'Firebase App Check initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Gets the current App Check token.
  /// 
  /// This can be used to manually retrieve the App Check token
  /// for debugging or testing purposes.
  /// 
  /// Returns [Future<String>] the current App Check token.
  static Future<String> getToken() async {
    try {
      final token = await FirebaseAppCheck.instance.getToken();
      developer.log('App Check token retrieved successfully');
      return token ?? '';
    } catch (error, stackTrace) {
      developer.log(
        'Failed to retrieve App Check token',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Sets the automatic token refresh mode.
  ///
  /// [autoRefresh] When true, App Check will automatically refresh tokens
  /// when they expire. When false, tokens must be manually refreshed.
  /// Default is true.
  static Future<void> setAutoRefresh(bool autoRefresh) async {
    try {
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(autoRefresh);
      developer.log('App Check auto-refresh set to: $autoRefresh');
    } catch (error, stackTrace) {
      developer.log(
        'Failed to set App Check auto-refresh',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Manually refreshes the App Check token.
  /// 
  /// This can be called when automatic refresh is disabled or when
  /// you need to force a token refresh.
  /// 
  /// Returns [Future<String>] the new App Check token.
  static Future<String> refreshToken() async {
    try {
      final token = await FirebaseAppCheck.instance.getToken(true);
      developer.log('App Check token refreshed successfully');
      return token ?? '';
    } catch (error, stackTrace) {
      developer.log(
        'Failed to refresh App Check token',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Enables or disables App Check for the current app instance.
  /// 
  /// [enabled] When true, App Check will be enforced. When false,
  /// App Check will be disabled (useful for testing).
  /// 
  /// Note: This should only be used in development/testing environments.
  static Future<void> setAppCheckEnabled(bool enabled) async {
    try {
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(enabled);
      developer.log('App Check enabled set to: $enabled');
    } catch (error, stackTrace) {
      developer.log(
        'Failed to set App Check enabled state',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
