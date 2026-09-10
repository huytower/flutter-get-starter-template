import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cc_micro_features/features/auth/domain/phone_auth_status.dart';
import 'package:cc_micro_features/features/auth/domain/repositories/firebase_auth_repository.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Semantic token for the default server-failure message.
/// Plain English default so this project-blind repository never depends on
/// the `message` module.
const String _serverError = 'Server error. Please try again later.';

@LazySingleton(as: FirebaseAuthRepository)
class FirebaseAuthRepositoryImpl implements FirebaseAuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepositoryImpl(this._firebaseAuth, this._googleSignIn);

  @override
  Future<Result<CcUserEntity, CcFailure>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      'Signing in with email: $email'.Log('FirebaseAuthRepository');
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        'Email sign in success: ${user.uid}'.Log('FirebaseAuthRepository');
        return Success(_mapFirebaseUserToEntity(user));
      } else {
        'Email sign in failed: user is null'.Log('FirebaseAuthRepository');
        return const Error(UnauthorizedFailure('Login failed'));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      'Email sign in Firebase Auth Exception: ${e.message}'.Log(
        'FirebaseAuthRepository',
      );
      return Error(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      'Email sign in error: $e'.Log('FirebaseAuthRepository');
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> signInAnonymously() async {
    try {
      'Signing in anonymously'.Log('FirebaseAuthRepository');
      final userCredential = await _firebaseAuth.signInAnonymously();
      final user = userCredential.user;
      if (user != null) {
        'Anonymous sign in success: ${user.uid}'.Log('FirebaseAuthRepository');
        return Success(_mapFirebaseUserToEntity(user));
      } else {
        'Anonymous sign in failed: user is null'.Log('FirebaseAuthRepository');
        return const Error(UnauthorizedFailure('Login failed'));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      'Anonymous sign in Firebase Auth Exception: ${e.message}'.Log(
        'FirebaseAuthRepository',
      );
      return Error(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      'Anonymous sign in error: $e'.Log('FirebaseAuthRepository');
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> signInWithGoogle() async {
    '[GOOGLE_SIGN_IN] 0. signInWithGoogle triggered'.Log(
      'FirebaseAuthRepository',
    );
    final credResult = await _getGoogleCredential();

    return credResult.when(
      (credential) async {
        '[GOOGLE_SIGN_IN] 5. Signing in to Firebase with Google credentials'
            .Log('FirebaseAuthRepository');
        return _signInWithCredential(credential);
      },
      (failure) {
        '[GOOGLE_SIGN_IN] ❌ Failed to get Google credential: ${failure.message}'
            .Log('FirebaseAuthRepository');
        return Error(failure);
      },
    );
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> signInWithApple() async {
    'signInWithApple triggered'.Log('FirebaseAuthRepository');
    final credResult = await _getAppleCredential();

    return credResult.when((credential) async {
      'Signing in to Firebase with Apple credentials'.Log(
        'FirebaseAuthRepository',
      );
      return _signInWithCredential(credential);
    }, (failure) => Error(failure));
  }

  /// Shared helper to handle the Apple Sign-In "dance" and return a Firebase
  /// credential.
  Future<Result<firebase_auth.AuthCredential, CcFailure>>
  _getAppleCredential() async {
    try {
      '[APPLE_SIGN_IN] 1. Starting Apple Sign In flow'.Log(
        'FirebaseAuthRepository',
      );
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);
      '[APPLE_SIGN_IN] 2. Nonce generated and hashed'.Log(
        'FirebaseAuthRepository',
      );

      '[APPLE_SIGN_IN] 3. Calling SignInWithApple.getAppleIDCredential'.Log(
        'FirebaseAuthRepository',
      );
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      '[APPLE_SIGN_IN] 4. Apple ID credential received'.Log(
        'FirebaseAuthRepository',
      );
      '[APPLE_SIGN_IN] 5. Details: email=${appleCredential.email}, familyName=${appleCredential.familyName}, givenName=${appleCredential.givenName}'
          .Log('FirebaseAuthRepository');
      '[APPLE_SIGN_IN] 6. identityToken length: ${appleCredential.identityToken?.length}'
          .Log('FirebaseAuthRepository');
      '[APPLE_SIGN_IN] 7. authorizationCode length: ${appleCredential.authorizationCode.length}'
          .Log('FirebaseAuthRepository');

      if (appleCredential.identityToken == null) {
        '[APPLE_SIGN_IN] ❌ Identity token is null!'.Log(
          'FirebaseAuthRepository',
        );
        return const Error(UnknownFailure('Apple identity token missing'));
      }

      final credential = firebase_auth.OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);
      '[APPLE_SIGN_IN] 8. Firebase AuthCredential created'.Log(
        'FirebaseAuthRepository',
      );

      return Success(credential);
    } on SignInWithAppleAuthorizationException catch (e) {
      '[APPLE_SIGN_IN] ❌ Apple Sign In Exception: code=${e.code}, message=${e.message}'
          .Log('FirebaseAuthRepository');
      if (e.code == AuthorizationErrorCode.canceled) {
        return const Error(UnauthorizedFailure('Authentication cancelled'));
      }
      return Error(ServerFailure(e.toString()));
    } catch (e, stack) {
      '[APPLE_SIGN_IN] ❌ Apple Auth Error: $e'.Log('FirebaseAuthRepository');
      '[APPLE_SIGN_IN] StackTrace: $stack'.Log('FirebaseAuthRepository');
      return const Error(
        UnknownFailure('An error occurred during Apple authentication'),
      );
    }
  }

  @override
  Stream<PhoneAuthStatus> verifyPhoneNumber({required String phoneNumber}) {
    final controller = StreamController<PhoneAuthStatus>();

    void onStatus(PhoneAuthStatus status) {
      if (!controller.isClosed) {
        '[PHONE_AUTH] 📞 Status update: ${status.runtimeType}'.Log(
          'FirebaseAuthRepository',
        );
        controller.add(status);
        if (status is PhoneAuthStatusCompleted ||
            status is PhoneAuthStatusFailed) {
          controller.close();
        }
      }
    }

    '[PHONE_AUTH] 1. Starting verifyPhoneNumber for: $phoneNumber'.Log(
      'FirebaseAuthRepository',
    );
    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        '[PHONE_AUTH] ✅ verificationCompleted (Auto-retrieval)'.Log(
          'FirebaseAuthRepository',
        );
        final result = await _signInWithCredential(credential);
        result.when(
          (u) => onStatus(PhoneAuthStatusCompleted(u)),
          (f) => onStatus(PhoneAuthStatusFailed(f)),
        );
      },
      verificationFailed: (e) {
        '[PHONE_AUTH] ❌ verificationFailed: code=${e.code}, message=${e.message}'
            .Log('FirebaseAuthRepository');
        onStatus(
          PhoneAuthStatusFailed(ServerFailure(e.message ?? _serverError)),
        );
      },
      codeSent: (id, token) {
        '[PHONE_AUTH] 📩 codeSent: verificationId=$id'.Log(
          'FirebaseAuthRepository',
        );
        onStatus(PhoneAuthStatusCodeSent(id, token));
      },
      codeAutoRetrievalTimeout: (id) {
        '[PHONE_AUTH] ⏰ codeAutoRetrievalTimeout: verificationId=$id'.Log(
          'FirebaseAuthRepository',
        );
        onStatus(PhoneAuthStatusAutoRetrievalTimeout(id));
      },
    );

    return controller.stream;
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    '[PHONE_AUTH] 2. signInWithPhoneNumber triggered | verificationId=$verificationId'
        .Log('FirebaseAuthRepository');
    return _signInWithCredential(
      firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      ),
    );
  }

  @override
  Future<Result<Unit, CcFailure>> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
      return const Success(unit);
    } catch (e) {
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  @override
  Future<Result<CcUserEntity?, CcFailure>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      return Success(user != null ? _mapFirebaseUserToEntity(user) : null);
    } catch (e) {
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  @override
  Stream<CcUserEntity?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) {
      return user != null ? _mapFirebaseUserToEntity(user) : null;
    });
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> updateDisplayName(String name) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Error(UnauthorizedFailure('Login failed'));
      }
      await user.updateDisplayName(name);
      await user.reload();
      final refreshed = _firebaseAuth.currentUser ?? user;
      return Success(_mapFirebaseUserToEntity(refreshed));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Error(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  Future<Result<CcUserEntity, CcFailure>> _signInWithCredential(
    firebase_auth.AuthCredential credential,
  ) async {
    try {
      '[APPLE_SIGN_IN] 9. _signInWithCredential started'.Log(
        'FirebaseAuthRepository',
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      '[APPLE_SIGN_IN] 10. _signInWithCredential success | userId=${user?.uid}'
          .Log('FirebaseAuthRepository');

      return switch (user) {
        firebase_auth.User u => Success(_mapFirebaseUserToEntity(u)),
        _ => const Error(UnauthorizedFailure('Login failed')),
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      '[APPLE_SIGN_IN] ❌ _signInWithCredential Firebase Error: code=${e.code}, message=${e.message}'
          .Log('FirebaseAuthRepository');
      return Error(ServerFailure(e.message ?? 'Server error'));
    } catch (e, stack) {
      '[APPLE_SIGN_IN] ❌ _signInWithCredential Unexpected Error: $e'.Log(
        'FirebaseAuthRepository',
      );
      '[APPLE_SIGN_IN] StackTrace: $stack'.Log('FirebaseAuthRepository');
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> linkWithGoogle() async {
    'linkWithGoogle triggered'.Log('FirebaseAuthRepository');
    final credResult = await _getGoogleCredential();

    return credResult.when((credential) async {
      'Linking Firebase account with Google credentials'.Log(
        'FirebaseAuthRepository',
      );
      return _linkWithCredential(credential);
    }, (failure) => Error(failure));
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> linkWithApple() async {
    'linkWithApple triggered'.Log('FirebaseAuthRepository');
    final credResult = await _getAppleCredential();

    return credResult.when((credential) async {
      'Linking Firebase account with Apple credentials'.Log(
        'FirebaseAuthRepository',
      );
      return _linkWithCredential(credential);
    }, (failure) => Error(failure));
  }

  /// Shared helper to handle the Google Sign-In "dance" and return a Firebase
  /// credential.
  Future<Result<firebase_auth.AuthCredential, CcFailure>>
  _getGoogleCredential() async {
    try {
      '[GOOGLE_SIGN_IN] 1. Initializing Google Sign In'.Log(
        'FirebaseAuthRepository',
      );
      await _googleSignIn.initialize();

      '[GOOGLE_SIGN_IN] 2. Authenticating Google User'.Log(
        'FirebaseAuthRepository',
      );
      final googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        '[GOOGLE_SIGN_IN] ❌ User cancelled or failed to authenticate'.Log(
          'FirebaseAuthRepository',
        );
        return const Error(UnauthorizedFailure('Authentication cancelled'));
      }

      '[GOOGLE_SIGN_IN] 3. Fetching authentication details'.Log(
        'FirebaseAuthRepository',
      );
      final googleAuth = await googleUser.authentication;
      '[GOOGLE_SIGN_IN] 4. Details received | idToken present: ${googleAuth.idToken != null}'
          .Log('FirebaseAuthRepository');

      return Success(
        firebase_auth.GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        ),
      );
    } on GoogleSignInException catch (e) {
      '[GOOGLE_SIGN_IN] ❌ GoogleSignInException: code=${e.code}'.Log(
        'FirebaseAuthRepository',
      );
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const Error(UnauthorizedFailure('Authentication cancelled'));
      }
      return Error(ServerFailure(e.toString()));
    } catch (e, stack) {
      '[GOOGLE_SIGN_IN] ❌ Unexpected Error: $e'.Log('FirebaseAuthRepository');
      '[GOOGLE_SIGN_IN] StackTrace: $stack'.Log('FirebaseAuthRepository');
      return const Error(
        UnknownFailure('An error occurred during Google authentication'),
      );
    }
  }

  @override
  Stream<PhoneAuthStatus> verifyPhoneNumberForLinking({
    required String phoneNumber,
  }) {
    final controller = StreamController<PhoneAuthStatus>();

    void onStatus(PhoneAuthStatus status) {
      if (!controller.isClosed) {
        controller.add(status);
        if (status is PhoneAuthStatusCompleted ||
            status is PhoneAuthStatusFailed ||
            status is PhoneAuthStatusAutoRetrievalTimeout) {
          controller.close();
        }
      }
    }

    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        // Link, not sign in — auto-retrieval must not replace the session.
        final result = await _linkWithCredential(credential);
        result.when(
          (u) => onStatus(PhoneAuthStatusCompleted(u)),
          (f) => onStatus(PhoneAuthStatusFailed(f)),
        );
      },
      verificationFailed: (e) => onStatus(
        PhoneAuthStatusFailed(ServerFailure(e.message ?? _serverError)),
      ),
      codeSent: (id, token) => onStatus(PhoneAuthStatusCodeSent(id, token)),
      codeAutoRetrievalTimeout: (id) =>
          onStatus(PhoneAuthStatusAutoRetrievalTimeout(id)),
    );

    return controller.stream;
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> linkWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) {
    return _linkWithCredential(
      firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      ),
    );
  }

  @override
  Future<Result<Unit, CcFailure>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Error(UnauthorizedFailure('Not logged in'));
      }

      try {
        await user.delete();
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          return const Error(
            ServerFailure('Please re-login before deleting your account.'),
          );
        }
        return Error(_mapLinkException(e));
      }

      return const Success(unit);
    } catch (e) {
      'Delete account error: $e'.Log('FirebaseAuthRepository');
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  Future<Result<CcUserEntity, CcFailure>> _linkWithCredential(
    firebase_auth.AuthCredential credential,
  ) async {
    try {
      '[APPLE_SIGN_IN] 11. _linkWithCredential started'.Log(
        'FirebaseAuthRepository',
      );
      final current = _firebaseAuth.currentUser;
      if (current == null) {
        '[APPLE_SIGN_IN] ❌ _linkWithCredential: No current user!'.Log(
          'FirebaseAuthRepository',
        );
        return const Error(UnauthorizedFailure('Login failed'));
      }
      final userCredential = await current.linkWithCredential(credential);
      final user = userCredential.user ?? current;
      '[APPLE_SIGN_IN] 12. _linkWithCredential success | userId=${user.uid}'
          .Log('FirebaseAuthRepository');

      return Success(_mapFirebaseUserToEntity(user));
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        '[APPLE_SIGN_IN] ⚠️ _linkWithCredential: Credential already in use, switching user...'
            .Log('FirebaseAuthRepository');
        // The credential is already linked to another Firebase user.
        // Sign in with the credential to switch to that user.
        try {
          final newCredential = await _firebaseAuth.signInWithCredential(
            credential,
          );
          final newUser = newCredential.user;
          if (newUser != null) {
            '[APPLE_SIGN_IN] 13. Switched to existing user: ${newUser.uid}'.Log(
              'FirebaseAuthRepository',
            );
            return Success(_mapFirebaseUserToEntity(newUser));
          }
          return const Error(UnauthorizedFailure('Login failed'));
        } catch (signInError) {
          '[APPLE_SIGN_IN] ❌ Sign in after link conflict failed: $signInError'
              .Log('FirebaseAuthRepository');
          return const Error(UnknownFailure('An error occurred'));
        }
      }
      '[APPLE_SIGN_IN] ❌ _linkWithCredential Firebase Error: code=${e.code}, message=${e.message}'
          .Log('FirebaseAuthRepository');
      return Error(_mapLinkException(e));
    } catch (e, stack) {
      '[APPLE_SIGN_IN] ❌ _linkWithCredential Unexpected Error: $e'.Log(
        'FirebaseAuthRepository',
      );
      '[APPLE_SIGN_IN] StackTrace: $stack'.Log('FirebaseAuthRepository');
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  /// Firebase's two standard linking-specific error codes get clearer
  /// messages; everything else falls back to the generic server message.
  CcFailure _mapLinkException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'credential-already-in-use':
        return const ServerFailure(
          'This account is already linked to a different user.',
        );
      case 'provider-already-linked':
        return const ServerFailure('This account is already linked.');
      default:
        return ServerFailure(e.message ?? 'Server error');
    }
  }

  CcUserEntity _mapFirebaseUserToEntity(firebase_auth.User user) {
    '[APPLE_SIGN_IN] 14. Mapping Firebase User to Entity: uid=${user.uid}, email=${user.email}, displayName=${user.displayName}'
        .Log('FirebaseAuthRepository');
    // Determine status based on Firebase properties
    CcUserStatus status = CcUserStatus.active;
    if (user.email != null && !user.emailVerified) {
      status = CcUserStatus.pendingVerification;
    }

    // Parse display name for first/last name
    String? firstName;
    String? lastName;
    final displayName = user.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      final nameParts = displayName.trim().split(' ');
      if (nameParts.length >= 2) {
        firstName = nameParts.first;
        lastName = nameParts.sublist(1).join(' ');
      } else if (nameParts.length == 1) {
        firstName = nameParts.first;
        lastName = '';
      }
    }

    return CcUserEntity(
      id: user.uid,
      email: user.email ?? '',
      phoneNumber: user.phoneNumber,
      status: status,
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      avatarUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      isPhoneVerified: user.phoneNumber != null,
      registeredDeviceIds: const [],
      // To be populated by device service
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: user.metadata.lastSignInTime ?? DateTime.now(),
      lastActiveAt: user.metadata.lastSignInTime,
      linkedProviderIds: user.providerData.map((p) => p.providerId).toList(),
    );
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
