import 'package:cc_sdk_data/domain/failures/cc_failure.dart';

/// The user dismissed the Google/Apple sheet. Not an error: the UI must close
/// any loading state silently instead of showing a message. Typed so callers
/// never have to compare [message] text.
class AuthCancelledFailure extends CcFailure {
  const AuthCancelledFailure() : super('Authentication cancelled');
}

/// Apple rejected the authorization with an unknown error (typically the Apple
/// ID on the device needs attention). The presentation layer maps this to a
/// localized message; [message] is only a fallback for logs.
class AppleVerificationFailure extends CcFailure {
  const AppleVerificationFailure()
    : super('Could not verify the Apple ID on this device');
}

/// Firebase needs a fresh login for a sensitive action (e.g. delete account)
/// and the provider cannot be re-authenticated in place (phone, email).
/// The presentation layer maps this to a localized message.
class RecentLoginRequiredFailure extends CcFailure {
  const RecentLoginRequiredFailure()
    : super('Recent login required for this action');
}
