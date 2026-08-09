import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:multiple_result/multiple_result.dart';

import '../phone_auth_status.dart';

/// Repository interface for authentication operations.
abstract class FirebaseAuthRepository {
  /// Signs in with email and password.
  Future<Result<CcUserEntity, CcFailure>> signInWithEmail(
    String email,
    String password,
  );

  /// Signs in anonymously.
  Future<Result<CcUserEntity, CcFailure>> signInAnonymously();

  /// Signs in with Google.
  Future<Result<CcUserEntity, CcFailure>> signInWithGoogle();

  /// Signs in with Apple.
  Future<Result<CcUserEntity, CcFailure>> signInWithApple();

  /// Verifies a phone number and returns a stream of domain statuses.
  Stream<PhoneAuthStatus> verifyPhoneNumber({required String phoneNumber});

  /// Signs in with a phone number and the SMS code received.
  Future<Result<CcUserEntity, CcFailure>> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  });

  /// Signs out the current user.
  Future<Result<Unit, CcFailure>> signOut();

  /// Gets the currently authenticated user.
  Future<Result<CcUserEntity?, CcFailure>> getCurrentUser();

  /// Streams the authentication state changes.
  Stream<CcUserEntity?> authStateChanges();

  /// Updates the current user's display name. Fails if there's no
  /// signed-in user (guests have no Firebase account to update).
  Future<Result<CcUserEntity, CcFailure>> updateDisplayName(String name);

  /// Links a Google account to the currently signed-in user, so they can
  /// subsequently log in with either method. Fails with `credential-already
  /// -in-use` if that Google identity already belongs to a different
  /// account, or `provider-already-linked` if already linked to this one.
  Future<Result<CcUserEntity, CcFailure>> linkWithGoogle();

  /// Starts phone verification for linking (not signing in) — deliberately
  /// separate from [verifyPhoneNumber], whose `verificationCompleted`
  /// auto-retrieval callback signs in with the credential; that would
  /// silently replace the current session instead of linking to it.
  Stream<PhoneAuthStatus> verifyPhoneNumberForLinking({
    required String phoneNumber,
  });

  /// Links a phone number (verified via [verifyPhoneNumberForLinking]) to
  /// the currently signed-in user.
  Future<Result<CcUserEntity, CcFailure>> linkWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  });
}
