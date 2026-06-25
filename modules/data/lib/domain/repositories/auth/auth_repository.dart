import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../../../features/lib/features/auth/presentation/bloc/domain_phone_auth_event.dart';
import '../../entities/auth/domain_user_entity.dart';

/// Repository interface for authentication operations.
abstract class AuthRepository {
  /// Signs in with email and password.
  Future<Result<DomainUserEntity, CcFailure>> signInWithEmail(
    String email,
    String password,
  );

  /// Signs in anonymously.
  Future<Result<DomainUserEntity, CcFailure>> signInAnonymously();

  /// Signs in with Google.
  Future<Result<DomainUserEntity, CcFailure>> signInWithGoogle();

  /// Signs in with Apple.
  Future<Result<DomainUserEntity, CcFailure>> signInWithApple();

  /// Verifies a phone number and returns a stream of events.
  Stream<DomainPhoneAuthEvent> verifyPhoneNumber({required String phoneNumber});

  /// Signs in with a phone number and the SMS code received.
  Future<Result<DomainUserEntity, CcFailure>> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  });

  /// Signs out the current user.
  Future<Result<Unit, CcFailure>> signOut();

  /// Gets the currently authenticated user.
  Future<Result<DomainUserEntity?, CcFailure>> getCurrentUser();

  /// Streams the authentication state changes.
  Stream<DomainUserEntity?> authStateChanges();
}
