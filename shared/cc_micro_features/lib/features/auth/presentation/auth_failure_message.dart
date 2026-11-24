import 'package:cc_micro_features/l10n/cc_mf_locale_keys.dart';
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:easy_localization/easy_localization.dart' as el;

import '../domain/auth_failures.dart';

/// Turns an auth [CcFailure] into the text shown to the user.
///
/// Typed failures are localized here (presentation) so the data layer never
/// carries translated or hardcoded user-facing strings; any other failure
/// keeps its own message.
String authFailureMessage(CcFailure failure) {
  return switch (failure) {
    AppleVerificationFailure() => el.tr(
      CcMfLocaleKeys.auth_apple_verify_failed,
    ),
    RecentLoginRequiredFailure() => el.tr(
      CcMfLocaleKeys.auth_recent_login_required,
    ),
    ReauthAccountMismatchFailure(:final expectedAccount) => el.tr(
      CcMfLocaleKeys.auth_reauth_account_mismatch,
      namedArgs: {'account': expectedAccount},
    ),
    _ => failure.message,
  };
}
