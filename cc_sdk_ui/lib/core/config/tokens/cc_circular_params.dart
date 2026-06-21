/// CcCircularParams: Design tokens for circular dimensions and border radii.
///
/// Purpose:
/// - Standardize border radius across the application.
/// - Provide semantic tokens for specific UI components (buttons, cards, dialogs).
abstract class CcCircularParams {
  // ==========================================================================
  // PRIMITIVE RADII
  // ==========================================================================

  static const double RADIUS_XS = 4;
  static const double RADIUS_SM = 8;
  static const double RADIUS_MD = 12;
  static const double RADIUS_LG = 16;
  static const double RADIUS_XL = 24;
  static const double RADIUS_XXL = 32;
  static const double RADIUS_MAX = 100;

  // ==========================================================================
  // SEMANTIC RADII
  // ==========================================================================

  /// Border radius for standard buttons.
  static const double BUTTON = RADIUS_SM;

  /// Border radius for cards and containers.
  static const double CARD = RADIUS_MD;

  /// Border radius for dialogs and bottom sheets.
  static const double DIALOG = RADIUS_LG;

  /// Border radius for text input fields.
  static const double INPUT = RADIUS_SM;

  /// Border radius for circle-like widgets (e.g., avatar placeholders, status indicators).
  static const double CIRCLE = 45;

  /// Radius used for specific square-top widgets.
  static const double SQUARE_TOP = 9;

  /// Radius for FAB (Floating Action Button).
  static const double FAB = 28;

  /// Radius for notch shoulders.
  static const double NOTCH = 12;
}
