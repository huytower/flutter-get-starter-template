import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../domain/entities/auth/cc_phone_auth_event.dart';
import '../../../domain/entities/auth/cc_user_entity.dart';
import '../../../domain/repositories/auth/cc_auth_repository.dart';

@LazySingleton(as: CcAuthRepository)
class FirebaseAuthRepositoryImpl implements CcAuthRepository {
  final FirebaseAuth _firebaseAuth;
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
        User u => Success(_mapFirebaseUserToEntity(u)),
        _ => const Error(UnauthorizedFailure(CcLocaleKeys.auth_login_failed)),
      };
    } on FirebaseAuthException catch (e) {
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
        User u => Success(_mapFirebaseUserToEntity(u)),
        _ => const Error(UnauthorizedFailure(CcLocaleKeys.auth_login_failed)),
      };
    } on FirebaseAuthException catch (e) {
      return Error(ServerFailure(e.message ?? CcLocaleKeys.app_error_server));
    } catch (e) {
      return const Error(UnknownFailure(CcLocaleKeys.app_error_general));
    }
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Error(UnauthorizedFailure(CcLocaleKeys.auth_login_failed));
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      return switch (user) {
        User u => Success(_mapFirebaseUserToEntity(u)),
        _ => const Error(UnauthorizedFailure(CcLocaleKeys.auth_login_failed)),
      };
    } on FirebaseAuthException catch (e) {
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

      final credential = OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      return switch (user) {
        User u => Success(_mapFirebaseUserToEntity(u)),
        _ => const Error(UnauthorizedFailure(CcLocaleKeys.auth_login_failed)),
      };
    } on FirebaseAuthException catch (e) {
      return Error(ServerFailure(e.message ?? CcLocaleKeys.app_error_server));
    } catch (e) {
      return const Error(UnknownFailure(CcLocaleKeys.app_error_general));
    }
  }

  @override
  Stream<CcPhoneAuthEvent> verifyPhoneNumber({required String phoneNumber}) {
    final controller = StreamController<CcPhoneAuthEvent>();

    void onEvent(CcPhoneAuthEvent event) {
      if (!controller.isClosed) {
        controller.add(event);
        if (event is CcPhoneVerificationCompleted ||
            event is CcPhoneVerificationFailed) {
          controller.close();
        }
      }
    }

    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        final result = await _signInWithCredential(credential);
        result.when(
          (u) => onEvent(CcPhoneVerificationCompleted(u)),
          (f) => onEvent(CcPhoneVerificationFailed(f)),
        );
      },
      verificationFailed: (e) => onEvent(
        CcPhoneVerificationFailed(
          ServerFailure(e.message ?? CcLocaleKeys.app_error_server),
        ),
      ),
      codeSent: (id, token) => onEvent(CcPhoneCodeSent(id, token)),
      codeAutoRetrievalTimeout: (id) =>
          onEvent(CcPhoneCodeAutoRetrievalTimeout(id)),
    );

    return controller.stream;
  }

  @override
  Future<Result<CcUserEntity, CcFailure>> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    return _signInWithCredential(
      PhoneAuthProvider.credential(
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
    AuthCredential credential,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      return switch (user) {
        User u => Success(_mapFirebaseUserToEntity(u)),
        _ => const Error(UnauthorizedFailure(CcLocaleKeys.auth_login_failed)),
      };
    } on FirebaseAuthException catch (e) {
      return Error(ServerFailure(e.message ?? CcLocaleKeys.app_error_server));
    } catch (e) {
      return const Error(UnknownFailure(CcLocaleKeys.app_error_general));
    }
  }

  CcUserEntity _mapFirebaseUserToEntity(User user) {
    return CcUserEntity(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
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
