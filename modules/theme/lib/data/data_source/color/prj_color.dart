import 'package:cc_sdk_ui/core/config/tokens/cc_base_colors.dart';
import 'package:flutter/material.dart';

/// PrjColors: The Single Source of Truth (SSOT) for the application's look and feel.
///
/// This file maps generic "Palette Primitives" from the SDK to specific
/// "Semantic Roles" for this application.
///
/// ## Principles
/// - **Role Ownership**: This is the ONLY place to define what a color "means" for this app.
/// - **Primitive Mapping**: Map names to `CcBaseColors` primitives.
/// - **Zero Redundancy**: If you change the primary color, change it HERE.
abstract final class PrjColors {
  PrjColors._();

  // ===========================================================================
  // BRAND & PRIMARY
  // ===========================================================================
  static const Color primary = CcBaseColors.brand500;
  static const Color onPrimary = CcBaseColors.white100;
  static const Color primaryContainer = CcBaseColors.brand300;
  static const Color onPrimaryContainer = CcBaseColors.neutral100;
  static const Color primaryPressed = CcBaseColors.brand600;
  static const Color primaryGradientEnd = CcBaseColors.brand900;

  // ===========================================================================
  // SECONDARY
  // ===========================================================================
  static const Color secondary = CcBaseColors.blue500;
  static const Color onSecondary = CcBaseColors.white100;
  static const Color secondaryContainer = CcBaseColors.blue700;
  static const Color onSecondaryContainer = CcBaseColors.white100;

  // ===========================================================================
  // STATUS & FEEDBACK
  // ===========================================================================
  static const Color success = CcBaseColors.successGreen;
  static const Color onSuccess = CcBaseColors.white100;

  static const Color warning = CcBaseColors.warningAmber;
  static const Color onWarning = CcBaseColors.neutral100;

  static const Color error = CcBaseColors.errorRed;
  static const Color onError = CcBaseColors.white100;

  static const Color info = CcBaseColors.infoBlue;
  static const Color onInfo = CcBaseColors.white100;

  // ===========================================================================
  // SURFACES & BACKGROUNDS
  // ===========================================================================

  // -- Light Mode
  static const Color background = CcBaseColors.white100;
  static const Color onBackground = CcBaseColors.gray900;

  static const Color surface = CcBaseColors.white100;
  static const Color onSurface = CcBaseColors.gray900;
  static const Color surfaceVariant = CcBaseColors.gray100;
  static const Color onSurfaceVariant = CcBaseColors.gray700;
  static const Color surfaceOverlay = CcBaseColors.gray200;

  // -- Dark Mode Specifics
  static const Color darkBackground = CcBaseColors.neutral100;
  static const Color darkOnBackground = CcBaseColors.white100;
  static const Color darkSurface = CcBaseColors.gray900;
  static const Color darkOnSurface = CcBaseColors.white100;
  static const Color darkSurfaceVariant = CcBaseColors.gray800;
  static const Color darkOnSurfaceVariant = CcBaseColors.gray300;
  static const Color darkDivider = CcBaseColors.gray50;

  // ===========================================================================
  // CONTENT & UTILS
  // ===========================================================================
  static const Color highEmphasis = CcBaseColors.gray900;
  static const Color mediumEmphasis = CcBaseColors.gray700;
  static const Color body = CcBaseColors.gray700;
  static const Color disabled = CcBaseColors.gray400;
  static const Color hint = CcBaseColors.gray400;

  static const Color outline = CcBaseColors.gray300;
  static const Color outlineVariant = CcBaseColors.gray200;
  static const Color divider = CcBaseColors.gray100;

  // Legacy/Common Aliases
  static const Color blue = CcBaseColors.blue500;
  static const Color pink = CcBaseColors.brand500;
  static const Color transparent = CcBaseColors.transparent;
}
