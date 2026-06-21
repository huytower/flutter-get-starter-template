import 'package:cc_sdk/domain/failures/cc_failure.dart';

import 'cc_user_entity.dart';

/// Sealed class representing the different states/events of a phone verification process.
sealed class CcPhoneAuthEvent {
  const CcPhoneAuthEvent();
}

/// Triggered when verification is automatically completed (e.g., auto-retrieval).
class CcPhoneVerificationCompleted extends CcPhoneAuthEvent {
  final CcUserEntity user;

  const CcPhoneVerificationCompleted(this.user);
}

/// Triggered when an error occurs during verification.
class CcPhoneVerificationFailed extends CcPhoneAuthEvent {
  final CcFailure failure;

  const CcPhoneVerificationFailed(this.failure);
}

/// Triggered when an SMS code has been sent to the phone number.
class CcPhoneCodeSent extends CcPhoneAuthEvent {
  final String verificationId;
  final int? resendToken;

  const CcPhoneCodeSent(this.verificationId, this.resendToken);
}

/// Triggered when the auto-retrieval of the SMS code has timed out.
class CcPhoneCodeAutoRetrievalTimeout extends CcPhoneAuthEvent {
  final String verificationId;

  const CcPhoneCodeAutoRetrievalTimeout(this.verificationId);
}
