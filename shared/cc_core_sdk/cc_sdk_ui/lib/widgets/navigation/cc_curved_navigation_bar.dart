import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:curved_navigation_bar_pro/curved_navigation_bar_pro.dart';
import 'package:flutter/material.dart';

/// A curved navigation bar component built on curved_navigation_bar_pro
/// with project-specific theming and configuration.
class CcCurvedNavigationBar extends StatelessWidget {
  const CcCurvedNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.activeColor,
    this.activeIconColor,
    this.inactiveColor,
    this.fabColor,
    this.barHeight,
    this.fabRadius,
    this.fabGap,
    this.fabSink,
    this.notchShoulderRadius,
    this.cornerRadius,
    this.contentPadding,
    this.elevation,
    this.shadowColor,
    this.animationDuration,
    this.animationCurve,
    this.activeTextStyle,
    this.inactiveTextStyle,
    this.inactiveIconSize,
    this.activeIconSize,
    this.navbarStyle,
  });

  /// List of navigation items to display
  final List<CcCurvedNavigationItem> items;

  /// Currently selected index
  final int currentIndex;

  /// Callback when an item is tapped
  final ValueChanged<int> onTap;

  /// Background color of the navigation bar
  final Color? backgroundColor;

  /// Color of the active item background
  final Color? activeColor;

  /// Color of the active icon
  final Color? activeIconColor;

  /// Color of inactive items
  final Color? inactiveColor;

  /// Color of the FAB (floating action button)
  final Color? fabColor;

  /// Height of the navigation bar
  final double? barHeight;

  /// Radius of the FAB
  final double? fabRadius;

  /// Gap between FAB and bar
  final double? fabGap;

  /// Sink depth of the FAB
  final double? fabSink;

  /// Radius of the notch shoulders
  final double? notchShoulderRadius;

  /// Corner radius of the bar
  final double? cornerRadius;

  /// Content padding inside the bar
  final double? contentPadding;

  /// Elevation (shadow) of the bar
  final double? elevation;

  /// Color of the shadow
  final Color? shadowColor;

  /// Duration of the animation
  final Duration? animationDuration;

  /// Curve for the animation
  final Curve? animationCurve;

  /// Text style for active labels
  final TextStyle? activeTextStyle;

  /// Text style for inactive labels
  final TextStyle? inactiveTextStyle;

  /// Size of inactive icons
  final double? inactiveIconSize;

  /// Size of active icons
  final double? activeIconSize;

  /// Built-in style preset to use
  // Note: CNBPStyles is from curved_navigation_bar_pro package
  // Use dynamic to avoid import issues when not using presets
  final dynamic navbarStyle;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    // Theme-aware default colors
    final themeBackgroundColor =
        backgroundColor ??
        (isDark ? CcBaseColors.gray900 : CcBaseColors.white100);
    final themeActiveColor = activeColor ?? CcBaseColors.brand500;
    final themeActiveIconColor = activeIconColor ?? CcBaseColors.white100;
    final themeInactiveColor =
        inactiveColor ??
        (isDark ? CcBaseColors.white50 : CcBaseColors.neutral50);
    final themeFabColor = fabColor ?? CcBaseColors.brand500;
    final themeShadowColor =
        shadowColor ??
        (isDark ? CcBaseColors.transparent : CcBaseColors.neutral10);

    return CurvedNavigationBarPro(
      items: items
          .map(
            (item) => CurvedNavigationItemPro(
              inactiveIcon: item.inactiveIcon,
              activeIcon: item.activeIcon,
              label: item.label,
              badgeText: item.badgeText,
              badgeColor: item.badgeColor,
              badgeTextColor: item.badgeTextColor,
              badgeWidget: item.badgeWidget,
            ),
          )
          .toList(),
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: themeBackgroundColor,
      activeColor: themeActiveColor,
      activeIconColor: themeActiveIconColor,
      inactiveColor: themeInactiveColor,
      fabColor: themeFabColor,
      barHeight: barHeight ?? 110,
      fabRadius: fabRadius ?? CcCircularParams.FAB,
      fabGap: fabGap ?? 3,
      fabSink: fabSink ?? 50,
      notchShoulderRadius: notchShoulderRadius ?? CcCircularParams.NOTCH,
      cornerRadius: cornerRadius ?? CcCircularParams.DIALOG,
      contentPadding: contentPadding ?? 8,
      elevation: elevation ?? 14,
      shadowColor: themeShadowColor,
      animationDuration: animationDuration ?? const Duration(milliseconds: 400),
      animationCurve: animationCurve ?? Curves.easeInOutCubic,
      activeTextStyle:
          activeTextStyle ??
          context.ccTextTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
      inactiveTextStyle:
          inactiveTextStyle ??
          context.ccTextTheme.labelSmall?.copyWith(
            fontSize: context.respFontSize(10.0),
            fontWeight: FontWeight.w400,
          ),
      inactiveIconSize: inactiveIconSize ?? 24,
      activeIconSize: activeIconSize ?? 22,
      navbarStyle: navbarStyle,
    );
  }
}

/// Data class for navigation items in CcCurvedNavigationBar
class CcCurvedNavigationItem {
  const CcCurvedNavigationItem({
    required this.inactiveIcon,
    required this.activeIcon,
    required this.label,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    this.badgeWidget,
  });

  /// Icon to show when item is inactive
  final IconData inactiveIcon;

  /// Icon to show when item is active
  final IconData activeIcon;

  /// Label text for the item
  final String label;

  /// Optional badge text (e.g., "3", "99+", "•")
  final String? badgeText;

  /// Optional custom badge color
  final Color? badgeColor;

  /// Optional custom badge text color
  final Color? badgeTextColor;

  /// Optional custom badge widget (overrides text-based badge)
  final Widget? badgeWidget;
}
