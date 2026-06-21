import 'package:flutter/material.dart';

/// Responsive design helper for multi-screen support.
///
/// Provides screen type detection, responsive breakpoints, and utilities
/// for building adaptive UIs across different device sizes (mobile, tablet, desktop).
class CcResponsiveHelper {
  // ==========================================================================
  // RESPONSIVE BREAKPOINTS
  // ==========================================================================

  /// Mobile devices: < 600px width
  static const double mobileBreakpoint = 600;

  /// Tablet devices: 600px - 900px width
  static const double tabletBreakpoint = 900;

  /// Desktop devices: > 900px width
  static const double desktopBreakpoint = 900;

  /// Small mobile devices: < 360px width (e.g., small phones, foldable covers)
  static const double smallMobileBreakpoint = 360;

  /// Large mobile devices: 360px - 600px width
  static const double largeMobileBreakpoint = 600;

  // ==========================================================================
  // SCREEN TYPE DETECTION
  // ==========================================================================

  /// Checks if the current screen is a mobile device.
  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < mobileBreakpoint;
  }

  /// Checks if the current screen is a tablet device.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Checks if the current screen is a desktop device.
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktopBreakpoint;
  }

  /// Checks if the current screen is a small mobile device.
  static bool isSmallMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < smallMobileBreakpoint;
  }

  /// Checks if the current screen is a large mobile device.
  static bool isLargeMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallMobileBreakpoint && width < mobileBreakpoint;
  }

  /// Gets the screen type as an enum.
  static ScreenType getScreenType(BuildContext context) {
    if (isDesktop(context)) return ScreenType.desktop;
    if (isTablet(context)) return ScreenType.tablet;
    if (isSmallMobile(context)) return ScreenType.smallMobile;
    return ScreenType.mobile;
  }

  // ==========================================================================
  // RESPONSIVE VALUE HELPERS
  // ==========================================================================

  /// Returns a value based on the current screen type.
  ///
  /// [mobile] - Value for mobile devices
  /// [tablet] - Value for tablet devices (optional, defaults to mobile)
  /// [desktop] - Value for desktop devices (optional, defaults to tablet)
  static T getValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.mobile:
      case ScreenType.smallMobile:
        return mobile;
    }
  }

  /// Returns a responsive value based on screen width.
  ///
  /// [context] - BuildContext to get screen size
  /// [smallMobile] - Value for small mobile (< 360px)
  /// [mobile] - Value for mobile (360px - 600px)
  /// [tablet] - Value for tablet (600px - 900px)
  /// [desktop] - Value for desktop (> 900px)
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T smallMobile,
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < smallMobileBreakpoint) return smallMobile;
    if (width < mobileBreakpoint) return mobile;
    if (width < desktopBreakpoint) return tablet;
    return desktop;
  }

  // ==========================================================================
  // RESPONSIVE DIMENSION HELPERS
  // ==========================================================================

  /// Returns a responsive width based on screen size.
  ///
  /// [context] - BuildContext to get screen size
  /// [mobileWidth] - Width for mobile devices (default: 100%)
  /// [tabletWidth] - Width for tablet devices (default: 80%)
  /// [desktopWidth] - Width for desktop devices (default: 60%)
  static double getResponsiveWidth({
    required BuildContext context,
    double? mobileWidth,
    double? tabletWidth,
    double? desktopWidth,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.desktop:
        return desktopWidth ?? screenWidth * 0.6;
      case ScreenType.tablet:
        return tabletWidth ?? screenWidth * 0.8;
      case ScreenType.mobile:
      case ScreenType.smallMobile:
        return mobileWidth ?? screenWidth;
    }
  }

  /// Returns a responsive padding based on screen size.
  ///
  /// [context] - BuildContext to get screen size
  /// [mobilePadding] - Padding for mobile devices (default: 16px)
  /// [tabletPadding] - Padding for tablet devices (default: 24px)
  /// [desktopPadding] - Padding for desktop devices (default: 32px)
  static double getResponsivePadding({
    required BuildContext context,
    double? mobilePadding,
    double? tabletPadding,
    double? desktopPadding,
  }) {
    return getValue(
      context: context,
      mobile: mobilePadding ?? 16.0,
      tablet: tabletPadding ?? 24.0,
      desktop: desktopPadding ?? 32.0,
    );
  }

  /// Returns a responsive font size based on screen size.
  ///
  /// [context] - BuildContext to get screen size
  /// [mobileFontSize] - Font size for mobile devices
  /// [tabletFontSize] - Font size for tablet devices (optional, scales by 1.2x)
  /// [desktopFontSize] - Font size for desktop devices (optional, scales by 1.4x)
  static double getResponsiveFontSize({
    required BuildContext context,
    required double mobileFontSize,
    double? tabletFontSize,
    double? desktopFontSize,
  }) {
    return getValue(
      context: context,
      mobile: mobileFontSize,
      tablet: tabletFontSize ?? mobileFontSize * 1.2,
      desktop: desktopFontSize ?? mobileFontSize * 1.4,
    );
  }

  // ==========================================================================
  // RESPONSIVE LAYOUT HELPERS
  // ==========================================================================

  /// Returns the number of columns for a grid layout based on screen size.
  ///
  /// [context] - BuildContext to get screen size
  /// [mobileColumns] - Columns for mobile devices (default: 1)
  /// [tabletColumns] - Columns for tablet devices (default: 2)
  /// [desktopColumns] - Columns for desktop devices (default: 3)
  static int getGridColumns({
    required BuildContext context,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
  }) {
    return getValue(
      context: context,
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 3,
    );
  }

  /// Returns whether to show a sidebar based on screen size.
  ///
  /// Sidebars are typically shown on tablet and desktop devices.
  static bool shouldShowSidebar(BuildContext context) {
    return !isMobile(context);
  }

  /// Returns whether to use a bottom navigation bar based on screen size.
  ///
  /// Bottom navigation is typically used on mobile devices.
  static bool shouldUseBottomNavigation(BuildContext context) {
    return isMobile(context);
  }

  /// Returns whether to use a drawer based on screen size.
  ///
  /// Drawers are typically used on tablet and desktop devices.
  static bool shouldUseDrawer(BuildContext context) {
    return !isMobile(context);
  }

  // ==========================================================================
  // ORIENTATION HELPERS
  // ==========================================================================

  /// Checks if the device is in portrait orientation.
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Checks if the device is in landscape orientation.
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Gets the screen width.
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Gets the screen height.
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Gets the safe area padding.
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Gets the device pixel ratio.
  static double devicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }
}

/// Enum representing different screen types.
enum ScreenType {
  /// Small mobile devices (< 360px width)
  smallMobile,

  /// Standard mobile devices (360px - 600px width)
  mobile,

  /// Tablet devices (600px - 900px width)
  tablet,

  /// Desktop devices (> 900px width)
  desktop,
}
