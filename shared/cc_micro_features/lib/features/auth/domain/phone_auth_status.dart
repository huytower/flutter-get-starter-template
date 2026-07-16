import 'package:cc_sdk_data/export_cc_sdk_data.dart';

/// Domain-level representation of a phone-number verification lifecycle.
///
/// This is intentionally state-management agnostic (no Bloc/GetX types) so the
/// `auth` domain and data layers stay clean per the project constitution
/// (rules #3 & #24). The presentation Bloc maps these statuses into its own
/// `PhoneAuthEvent`/`PhoneAuthState`.
sealed class PhoneAuthStatus {
  const PhoneAuthStatus();
}

/// Verification has been initiated for [phoneNumber].
class PhoneAuthStatusStarted extends PhoneAuthStatus {
  const PhoneAuthStatusStarted(this.phoneNumber);

  final String phoneNumber;
}

/// An SMS code has been sent. [resendToken] may be null.
class PhoneAuthStatusCodeSent extends PhoneAuthStatus {
  const PhoneAuthStatusCodeSent(this.verificationId, this.resendToken);

  final String verificationId;
  final int? resendToken;
}

/// Verification finished automatically (e.g. auto-retrieval).
class PhoneAuthStatusCompleted extends PhoneAuthStatus {
  const PhoneAuthStatusCompleted(this.user);

  final CcUserEntity user;
}

/// Verification failed with [failure].
class PhoneAuthStatusFailed extends PhoneAuthStatus {
  const PhoneAuthStatusFailed(this.failure);

  final CcFailure failure;
}

/// The SMS auto-retrieval timeout elapsed; the user may still enter the code.
class PhoneAuthStatusAutoRetrievalTimeout extends PhoneAuthStatus {
  const PhoneAuthStatusAutoRetrievalTimeout(this.verificationId);

  final String verificationId;
}
