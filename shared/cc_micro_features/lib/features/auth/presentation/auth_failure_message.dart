import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;

import '../domain/auth_failures.dart';

/// Turns an auth [CcFailure] into the text shown to the user.
///
/// Typed failures are localized here (presentation) so the data layer never
/// carries translated or hardcoded user-facing strings; any other failure
/// keeps its own message.
String authFailureMessage(CcFailure failure) {
  return switch (failure) {
    AppleVerificationFailure() => el.tr(CcLocaleKeys.auth_apple_verify_failed),
    RecentLoginRequiredFailure() => el.tr(
      CcLocaleKeys.auth_recent_login_required,
    ),
    _ => failure.message,
  };
}
