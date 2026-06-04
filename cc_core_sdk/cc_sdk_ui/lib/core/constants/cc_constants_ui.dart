/// UI constants for dialogs, snackbars, and toasts
abstract class CcConstantsUI {
  // ==========================================================================
  // TOAST CONSTANTS
  // ==========================================================================

  /// Toast duration values
  static const int toastLengthShort = 1;
  static const int toastLengthLong = 2;

  /// Toast gravity positions
  static const int toastGravityBottom = 0;
  static const int toastGravityCenter = 1;
  static const int toastGravityTop = 2;

  /// Default toast values
  static const int defaultToastDuration = 1;
  static const double defaultToastBackgroundRadius = 20.0;
  static const double defaultToastBottomPosition = 100.0;

  // ==========================================================================
  // SNACKBAR CONSTANTS
  // ==========================================================================

  /// Default snackbar duration in milliseconds
  static const int defaultSnackbarDurationMs = 1300;

  /// Default snackbar margin
  static const double defaultSnackbarMargin = 8.0;

  /// Default snackbar text line height
  static const double defaultSnackbarTextHeight = 1.2;

  // ==========================================================================
  // DIALOG CONSTANTS
  // ==========================================================================

  /// Default dialog border radius
  static const double defaultDialogBorderRadius = 10.0;

  /// Default barrier opacity for dialogs
  static const double defaultBarrierOpacity = 0.5;

  /// Default barrier opacity for loading dialogs
  static const double defaultLoadingBarrierOpacity = 0.3;

  /// Auto-dismiss delay for dialogs
  static const Duration dialogAutoDismissDelay = Duration(seconds: 2);

  /// Default dialog inset padding
  static const double defaultDialogInsetPadding = 15.0;

  /// Default dialog corner radius
  static const double defaultDialogCornerRadius = 16.0;

  /// Default dialog blur sigma for backdrop filter
  static const double dialogBlurSigma = 7.0;

  // ==========================================================================
  // BOTTOM SHEET CONSTANTS
  // ==========================================================================

  /// Default bottom sheet border radius
  static const double defaultBottomSheetBorderRadius = 10.0;

  /// Default bottom sheet enable drag
  static const bool defaultBottomSheetEnableDrag = true;

  // ==========================================================================
  // HEADER WIDGET CONSTANTS
  // ==========================================================================

  /// Default header height
  static const double defaultHeaderHeight = 76.0;

  /// Default right button width
  static const double defaultRightButtonWidth = 103.0;

  /// Default icon height
  static const double defaultIconHeight = 35.0;

  /// Default bottom padding for large screens
  static const double headerBottomPaddingLarge = 3.0;

  /// Default bottom padding for small screens
  static const double headerBottomPaddingSmall = 6.0;

  /// Default bottom padding for medium screens
  static const double headerBottomPaddingMedium = 12.0;

  /// Default space left for large screens
  static const double headerSpaceLeftLarge = 16.5;

  /// Default space left for small screens
  static const double headerSpaceLeftSmall = 12.0;
}
