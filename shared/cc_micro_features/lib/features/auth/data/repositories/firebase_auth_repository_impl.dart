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
    try {
      'Initializing Google Sign In'.Log('FirebaseAuthRepository');
      await _googleSignIn.initialize();
      'Authenticating Google User'.Log('FirebaseAuthRepository');
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      'Google authentication received'.Log('FirebaseAuthRepository');

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: null, // Access token is now separate in 7.x
        idToken: googleAuth.idToken,
      );

      'Signing in to Firebase with Google credentials'.Log(
        'FirebaseAuthRepository',
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        'Firebase sign in success: ${user.uid}'.Log('FirebaseAuthRepository');
        return Success(_mapFirebaseUserToEntity(user));
      } else {
        'Firebase sign in failed: user is null'.Log('FirebaseAuthRepository');
        return const Error(UnauthorizedFailure('Login failed'));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      'Firebase Auth Exception: ${e.message}'.Log('FirebaseAuthRepository');
      return Error(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      'Google Sign In Error: $e'.Log('FirebaseAuthRepository');
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> signInWithApple() async {
    try {
      'Starting Apple Sign In flow'.Log('FirebaseAuthRepository');
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      'Apple ID credential received'.Log('FirebaseAuthRepository');

      final credential = firebase_auth.OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      'Signing in to Firebase with Apple credentials'.Log(
        'FirebaseAuthRepository',
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        'Apple sign in success: ${user.uid}'.Log('FirebaseAuthRepository');
        return Success(_mapFirebaseUserToEntity(user));
      } else {
        'Apple sign in failed: user is null'.Log('FirebaseAuthRepository');
        return const Error(UnauthorizedFailure('Login failed'));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      'Apple sign in Firebase Auth Exception: ${e.message}'.Log(
        'FirebaseAuthRepository',
      );
      return Error(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      'Apple sign in error: $e'.Log('FirebaseAuthRepository');
      return const Error(UnknownFailure('An error occurred'));
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
    } catch (e) {
      return const Error(UnknownFailure('An error occurred'));
    }
  }

  CcUserEntity _mapFirebaseUserToEntity(firebase_auth.User user) {
    // Determine status based on Firebase properties
    CcUserStatus status = CcUserStatus.active;
    if (user.email != null && !user.emailVerified) {
      status = CcUserStatus.pendingVerification;
    }

    return CcUserEntity(
      id: user.uid,
      email: user.email ?? '',
      phoneNumber: user.phoneNumber,
      status: status,
      firstName: user.displayName?.split(' ').first,
      lastName: user.displayName?.contains(' ') == true
          ? user.displayName?.split(' ').last
          : null,
      avatarUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      isPhoneVerified: user.phoneNumber != null,
      registeredDeviceIds: const [],
      // To be populated by device service
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: user.metadata.lastSignInTime ?? DateTime.now(),
      lastActiveAt: user.metadata.lastSignInTime,
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
