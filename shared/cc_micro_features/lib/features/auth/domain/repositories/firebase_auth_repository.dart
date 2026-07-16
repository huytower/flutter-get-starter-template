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
}
