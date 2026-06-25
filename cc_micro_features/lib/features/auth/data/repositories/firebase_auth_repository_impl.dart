import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:cc_micro_features/features/auth/domain/repositories/firebase_auth_repository.dart';
import 'package:cc_micro_features/features/auth/presentation/bloc/phone_auth_event.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
      return switch (user) {
        firebase_auth.User u => Success(_mapFirebaseUserToEntity(u)),
        _ => const Error(UnauthorizedFailure(CcLocaleKeys.auth_login_failed)),
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Error(ServerFailure(e.message ?? CcLocaleKeys.app_error_server));
    } catch (e) {
      return const Error(UnknownFailure(CcLocaleKeys.app_error_general));
    }
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      final user = userCredential.user;
      return switch (user) {
        firebase_auth.User u => Success(_mapFirebaseUserToEntity(u)),
        _ => const Error(UnauthorizedFailure(CcLocaleKeys.auth_login_failed)),
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Error(ServerFailure(e.message ?? CcLocaleKeys.app_error_server));
    } catch (e) {
      return const Error(UnknownFailure(CcLocaleKeys.app_error_general));
    }
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: null, // Access token is now separate in 7.x
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      return switch (user) {
        firebase_auth.User u => Success(_mapFirebaseUserToEntity(u)),
        _ => const Error(UnauthorizedFailure(CcLocaleKeys.auth_login_failed)),
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Error(ServerFailure(e.message ?? CcLocaleKeys.app_error_server));
    } catch (e) {
      return const Error(UnknownFailure(CcLocaleKeys.app_error_general));
    }
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final credential = firebase_auth.OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      return switch (user) {
        firebase_auth.User u => Success(_mapFirebaseUserToEntity(u)),
        _ => const Error(UnauthorizedFailure(CcLocaleKeys.auth_login_failed)),
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Error(ServerFailure(e.message ?? CcLocaleKeys.app_error_server));
    } catch (e) {
      return const Error(UnknownFailure(CcLocaleKeys.app_error_general));
    }
  }

  @override
  Stream<PhoneAuthEvent> verifyPhoneNumber({required String phoneNumber}) {
    final controller = StreamController<PhoneAuthEvent>();

    void onEvent(PhoneAuthEvent event) {
      if (!controller.isClosed) {
        controller.add(event);
        if (event is PhoneVerificationCompleted ||
            event is PhoneVerificationFailed) {
          controller.close();
        }
      }
    }

    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        final result = await _signInWithCredential(credential);
        result.when(
          (u) => onEvent(PhoneVerificationCompleted(u)),
          (f) => onEvent(PhoneVerificationFailed(f)),
        );
      },
      verificationFailed: (e) => onEvent(
        PhoneVerificationFailed(
          ServerFailure(e.message ?? CcLocaleKeys.app_error_server),
        ),
      ),
      codeSent: (id, token) => onEvent(PhoneCodeSent(id, token)),
      codeAutoRetrievalTimeout: (id) =>
          onEvent(PhoneCodeAutoRetrievalTimeout(id)),
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
      return const Error(UnknownFailure(CcLocaleKeys.app_error_general));
    }
  }

  @override
  Future<Result<CcUserEntity?, CcFailure>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      return Success(user != null ? _mapFirebaseUserToEntity(user) : null);
    } catch (e) {
      return const Error(UnknownFailure(CcLocaleKeys.app_error_general));
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
        _ => const Error(UnauthorizedFailure(CcLocaleKeys.auth_login_failed)),
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Error(ServerFailure(e.message ?? CcLocaleKeys.app_error_server));
    } catch (e) {
      return const Error(UnknownFailure(CcLocaleKeys.app_error_general));
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
      registeredDeviceIds: const [], // To be populated by device service
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
