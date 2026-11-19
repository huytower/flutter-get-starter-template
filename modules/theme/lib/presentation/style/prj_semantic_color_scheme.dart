import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// App-specific (personal-finance) semantic colors, read as
/// `context.ccColorScheme.investment` etc. Moved out of cc_sdk_ui because
/// "investment" and "liability" are this app's business concepts.
extension PrjSemanticColorScheme on ColorScheme {
  Color get investment => CcBaseColors.yellow600;

  Color get investmentSecondary =>
      CcBaseColors.yellow600.withValues(alpha: 0.8);

  Color get liability => CcBaseColors.violet600;

  Color get liabilitySecondary => CcBaseColors.violet600.withValues(alpha: 0.8);
}
