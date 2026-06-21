import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter/material.dart';

/// Extension on BuildContext to easily access project-standard theme properties.
///
/// This provides a state-management and font-agnostic way for widgets in the
/// UI library to synchronize with the application's theme.
extension CcContextExtension on BuildContext {
  /// Access the Material TextTheme.
  TextTheme get ccTextTheme => Theme.of(this).textTheme;

  /// Access the Material ColorScheme.
  ColorScheme get ccColorScheme => Theme.of(this).colorScheme;

  /// Access the overall Theme.
  ThemeData get ccTheme => Theme.of(this);

  /// Check if the current theme is dark.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ==========================================================================
  // RESPONSIVE HELPERS
  // ==========================================================================

  /// Check if the current orientation is portrait.
  bool get isPortrait => CcResponsiveHelper.isPortrait(this);

  /// Check if the current orientation is landscape.
  bool get isLandscape => CcResponsiveHelper.isLandscape(this);

  /// Checks if the current screen is a mobile device.
  bool get isMobile => CcResponsiveHelper.isMobile(this);

  /// Checks if the current screen is a tablet device.
  bool get isTablet => CcResponsiveHelper.isTablet(this);

  /// Checks if the current screen is a desktop device.
  bool get isDesktop => CcResponsiveHelper.isDesktop(this);

  /// Checks if the current screen is a small mobile device.
  bool get isSmallMobile => CcResponsiveHelper.isSmallMobile(this);

  /// Checks if the current screen is a large mobile device.
  bool get isLargeMobile => CcResponsiveHelper.isLargeMobile(this);

  /// Gets the current screen width.
  double get screenWidth => CcResponsiveHelper.screenWidth(this);

  /// Gets the current screen height.
  double get screenHeight => CcResponsiveHelper.screenHeight(this);

  /// Gets the screen type as an enum.
  ScreenType get screenType => CcResponsiveHelper.getScreenType(this);
}
