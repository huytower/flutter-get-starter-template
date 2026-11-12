import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:catcher_2/catcher_2.dart';
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
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        return Success(_mapFirebaseUserToEntity(user));
      } else {
        return const Error(UnauthorizedFailure('Login failed'));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Error(ServerFailure(e.message ?? 'Server error'));
    } catch (_) {
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      final user = userCredential.user;
      if (user != null) {
        return Success(_mapFirebaseUserToEntity(user));
      } else {
        return const Error(UnauthorizedFailure('Login failed'));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Error(ServerFailure(e.message ?? 'Server error'));
    } catch (_) {
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> signInWithGoogle() async {
    final credResult = await _getGoogleCredential();

    return credResult.when(
      (credential) async {
        return _signInWithCredential(credential);
      },
      (failure) {
        return Error(failure);
      },
    );
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> signInWithApple() async {
    'signInWithApple started'.Log('FirebaseAuthRepositoryImpl');
    final credResult = await _getAppleCredential();

    return credResult.when(
      (apple) async {
        'Apple credential acquired successfully, signing in with Firebase credential'
            .Log('FirebaseAuthRepositoryImpl');
        final signInResult = await _signInWithCredential(apple.credential);
        if (signInResult.isError()) {
          final failure = signInResult.tryGetError()!;
          'signInWithCredential error: ${failure.message}'.Log(
            'FirebaseAuthRepositoryImpl',
          );
          Catcher2.reportCheckedError(
            Exception('Apple Sign-In Firebase Auth error: ${failure.message}'),
            StackTrace.current,
          );
          return signInResult;
        }
        return _applyAppleFullName(
          signInResult.tryGetSuccess()!,
          apple.fullName,
        );
      },
      (failure) {
        'signInWithApple failed at credential stage: ${failure.message}'.Log(
          'FirebaseAuthRepositoryImpl',
        );
        return Error(failure);
      },
    );
  }

  /// Apple only returns the user's name on the FIRST authorization of the app
  /// and Firebase does not copy it into the profile, so it must be saved here.
  /// Without this the profile shows an empty name and the app ends up asking
  /// the user for information Apple already provided (App Review guideline 4,
  /// Sign in with Apple design requirements).
  ///
  /// Best effort: a failure to store the name must never fail the sign-in.
  Future<Result<CcUserEntity, CcFailure>> _applyAppleFullName(
    CcUserEntity signedIn,
    String? fullName,
  ) async {
    if (fullName == null || fullName.isEmpty) return Success(signedIn);
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return Success(signedIn);
      if ((user.displayName ?? '').trim().isNotEmpty) return Success(signedIn);
      await user.updateDisplayName(fullName);
      await user.reload();
      final refreshed = _firebaseAuth.currentUser ?? user;
      return Success(_mapFirebaseUserToEntity(refreshed));
    } catch (e) {
      'Could not store the Apple full name: $e'.Log('FirebaseAuthRepositoryImpl');
      return Success(signedIn);
    }
  }

  /// Joins the given/family name Apple returned; null when Apple sent none.
  String? _appleFullName(AuthorizationCredentialAppleID credential) {
    final parts = [credential.givenName, credential.familyName]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);
    final name = parts.join(' ');
    return name.isEmpty ? null : name;
  }

  /// Shared helper to handle the Apple Sign-In "dance" and return a Firebase
  /// credential together with the full name Apple provided (first sign-in only).
  Future<Result<({firebase_auth.AuthCredential credential, String? fullName}),
      CcFailure>>
  _getAppleCredential() async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        final err = Exception(
          '[AppleSignInTrace] Step 1: SignInWithApple.isAvailable() returned FALSE on this device',
        );
        Catcher2.reportCheckedError(err, StackTrace.current);
        return const Error(
          UnauthorizedFailure('Apple Sign-In is not supported on this device'),
        );
      }

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (appleCredential.identityToken == null) {
        final err = Exception(
          '[AppleSignInTrace] Step 2: Apple identityToken is NULL in response',
        );
        Catcher2.reportCheckedError(err, StackTrace.current);
        return const Error(UnknownFailure('Apple identity token missing'));
      }

      final credential = firebase_auth.OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      return Success((
        credential: credential,
        fullName: _appleFullName(appleCredential),
      ));
    } on SignInWithAppleAuthorizationException catch (e, stack) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const Error(UnauthorizedFailure('Authentication cancelled'));
      }
      final traceErr = Exception(
        '[AppleSignInTrace] Authorization Failed | Code: ${e.code} | Message: ${e.message}',
      );
      Catcher2.reportCheckedError(traceErr, stack);
      if (e.code == AuthorizationErrorCode.unknown) {
        return const Error(
          UnauthorizedFailure(
            'Không thể xác thực Apple ID. Vui lòng kiểm tra tài khoản Apple ID trong Cài đặt iPhone của bạn và thử lại.',
          ),
        );
      }
      return Error(ServerFailure('Apple Sign-In failed: ${e.message}'));
    } catch (e, stack) {
      final traceErr = Exception('[AppleSignInTrace] Unexpected Error: $e');
      Catcher2.reportCheckedError(traceErr, stack);
      return Error(
        UnknownFailure('An error occurred during Apple authentication: $e'),
      );
    }
  }

  @override
  Stream<PhoneAuthStatus> verifyPhoneNumber({required String phoneNumber}) {
    final controller = StreamController<PhoneAuthStatus>();

    void onStatus(PhoneAuthStatus status) {
      if (!controller.isClosed) {
        controller.add(status);
        if (status is PhoneAuthStatusCompleted ||
            status is PhoneAuthStatusFailed) {
          controller.close();
        }
      }
    }

    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        final result = await _signInWithCredential(credential);
        result.when(
          (u) => onStatus(PhoneAuthStatusCompleted(u)),
          (f) => onStatus(PhoneAuthStatusFailed(f)),
        );
      },
      verificationFailed: (e) {
        onStatus(
          PhoneAuthStatusFailed(ServerFailure(e.message ?? _serverError)),
        );
      },
      codeSent: (id, token) {
        onStatus(PhoneAuthStatusCodeSent(id, token));
      },
      codeAutoRetrievalTimeout: (id) {
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
    } catch (_) {
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  @override
  Future<Result<CcUserEntity?, CcFailure>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      return Success(user != null ? _mapFirebaseUserToEntity(user) : null);
    } catch (_) {
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
    } catch (_) {
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  Future<Result<CcUserEntity, CcFailure>> _signInWithCredential(
    firebase_auth.AuthCredential credential,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      return switch (user) {
        firebase_auth.User u => Success(_mapFirebaseUserToEntity(u)),
        _ => const Error(UnauthorizedFailure('Login failed')),
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Error(ServerFailure(e.message ?? 'Server error'));
    } catch (_) {
      return const Error(UnknownFailure('Sign in failed'));
    }
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> linkWithGoogle() async {
    final credResult = await _getGoogleCredential();

    return credResult.when((credential) async {
      return _linkWithCredential(credential);
    }, (failure) => Error(failure));
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> linkWithApple() async {
    final credResult = await _getAppleCredential();

    return credResult.when((apple) async {
      final linked = await _linkWithCredential(apple.credential);
      if (linked.isError()) return linked;
      return _applyAppleFullName(linked.tryGetSuccess()!, apple.fullName);
    }, (failure) => Error(failure));
  }

  /// Shared helper to handle the Google Sign-In "dance" and return a Firebase
  /// credential.
  Future<Result<firebase_auth.AuthCredential, CcFailure>>
  _getGoogleCredential() async {
    try {
      await _googleSignIn.initialize();
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;

      return Success(
        firebase_auth.GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        ),
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const Error(UnauthorizedFailure('Authentication cancelled'));
      }
      return Error(ServerFailure(e.toString()));
    } catch (_) {
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
      return Error(UnknownFailure('Delete account failed: $e'));
    }
  }

  Future<Result<CcUserEntity, CcFailure>> _linkWithCredential(
    firebase_auth.AuthCredential credential,
  ) async {
    try {
      final current = _firebaseAuth.currentUser;
      if (current == null) {
        return const Error(UnauthorizedFailure('Login failed'));
      }
      final userCredential = await current.linkWithCredential(credential);
      final user = userCredential.user ?? current;

      return Success(_mapFirebaseUserToEntity(user));
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        // The credential is already linked to another Firebase user.
        // Sign in with the credential to switch to that user.
        try {
          final newCredential = await _firebaseAuth.signInWithCredential(
            credential,
          );
          final newUser = newCredential.user;
          if (newUser != null) {
            return Success(_mapFirebaseUserToEntity(newUser));
          }
          return const Error(UnauthorizedFailure('Login failed'));
        } catch (signInError) {
          return Error(UnknownFailure('Sign in conflict: $signInError'));
        }
      }
      return Error(_mapLinkException(e));
    } catch (e) {
      return Error(UnknownFailure('Link account failed: $e'));
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
