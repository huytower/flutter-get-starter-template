import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Mixin providing curved navigation bar functionality with Home, Notification, and Profile items.
///
/// This mixin provides a standardized implementation of the curved navigation bar
/// that can be used across different views and state management approaches (Bloc, GetX, Provider, etc.).
///
/// The mixin is state-management agnostic and only requires implementing:
/// - [currentIndex]: to provide the current navigation index
/// - [setIndex]: to handle index changes
///
/// Usage with GetX:
/// ```dart
/// class MyGetXView extends GetxController with CcCurvedNavigationMixin {
///   final currentIndex = 0.obs;
///
///   @override
///   int get currentIndex => this.currentIndex.value;
///
///   @override
///   void setIndex(int index) {
///     this.currentIndex.value = index;
///   }
/// }
/// ```
///
/// Usage with Bloc:
/// ```dart
/// class MyBlocView extends StatelessWidget with CcCurvedNavigationMixin {
///   @override
///   int get currentIndex => context.read<MyBloc>().state.currentIndex;
///
///   @override
///   void setIndex(int index) {
///     context.read<MyBloc>().add(NavigationIndexChanged(index));
///   }
/// }
/// ```
///
/// Usage with Provider:
/// ```dart
/// class MyProviderView extends StatelessWidget with CcCurvedNavigationMixin {
///   @override
///   int get currentIndex => context.watch<MyProvider>().currentIndex;
///
///   @override
///   void setIndex(int index) {
///     context.read<MyProvider>().setIndex(index);
///   }
/// }
/// ```
mixin CcCurvedNavigationMixin {
  /// Current index of the selected navigation item
  /// Must be implemented by the consuming class based on the state management approach
  int get currentIndex;

  /// Sets the current navigation index
  /// Must be implemented by the consuming class based on the state management approach
  void setIndex(int index);

  /// Navigation items for the curved navigation bar
  /// Default: Home, Notification, Profile
  List<CcCurvedNavigationItem> get navigationItems => [
    CcCurvedNavigationItem(
      inactiveIcon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: el.tr(CcLocaleKeys.nav_dashboard),
    ),
    CcCurvedNavigationItem(
      inactiveIcon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      label: el.tr(CcLocaleKeys.nav_notification),
    ),
    CcCurvedNavigationItem(
      inactiveIcon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: el.tr(CcLocaleKeys.nav_profile),
    ),
  ];

  /// Optional custom color overrides
  /// Note: These are theme-aware by default and will respond to theme changes
  /// Override these if you need custom colors that don't change with the theme
  Color? get navigationBackgroundColor => null;

  Color? get navigationActiveColor => null;

  Color? get navigationActiveIconColor => null;

  Color? get navigationInactiveColor => null;

  Color? get navigationFabColor => null;

  /// Optional custom dimension overrides
  double? get navigationBarHeight => null;

  double? get navigationFabRadius => null;

  /// Optional built-in style preset
  // Note: CNBPStyles is from curved_navigation_bar_pro package
  // Import it if you want to use built-in presets
  dynamic get navbarStyle => null;

  /// Builds the curved navigation bar widget
  Widget buildCurvedNavigationBar() {
    return CcCurvedNavigationBar(
      items: navigationItems,
      currentIndex: currentIndex,
      onTap: setIndex,
      backgroundColor: navigationBackgroundColor,
      activeColor: navigationActiveColor,
      activeIconColor: navigationActiveIconColor,
      inactiveColor: navigationInactiveColor,
      fabColor: navigationFabColor,
      barHeight: navigationBarHeight,
      fabRadius: navigationFabRadius,
      navbarStyle: navbarStyle,
    );
  }
}
