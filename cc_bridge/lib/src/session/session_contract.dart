import 'package:cc_sdk_data/export_cc_sdk_data.dart';

/// Contract for managing and accessing the current user session.
///
/// This allows any feature (Dashboard, Profile, Payment) to check
/// authentication status without depending on the Auth or Data modules.
abstract class SessionContract {
  /// Whether the user is currently authenticated.
  bool get isAuthenticated;

  /// Returns the current user information, or null if not logged in.
  CcUserEntity? get currentUser;

  /// Stream of the current user for reactive UI updates.
  Stream<CcUserEntity?> get userStream;

  /// Logic to clear the session (logout)
  Future<void> clearSession();
}
