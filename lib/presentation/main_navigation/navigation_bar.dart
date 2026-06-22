import 'package:auto_route/auto_route.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import 'logic/navigation_logic_mixin.dart';
import 'tabs/home_tab_content.dart';
import 'tabs/notification_tab_content.dart';
import 'tabs/profile_tab_content.dart';
import 'tabs/quick_test_tab_content.dart';

/// Main navigation view with curved navigation bar.
@RoutePage()
class NavigationBar extends StatefulWidget {
  const NavigationBar({super.key});

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar>
    with CcCurvedNavigationMixin, DoubleBackToExitMixin, NavigationLogicMixin {
  // Navigation indices
  static const int _indexHome = 0;
  static const int _indexNotification = 1;
  static const int _indexProfile = 2;

  // Singleton to persist index across hot reload
  static int? _persistentIndex;

  @override
  void initState() {
    super.initState();
    initNavigationLogic();
  }

  @override
  bool handleCustomNavigation() {
    if (currentIndex != _indexHome) {
      setIndex(_indexHome);
      return true;
    }
    return false;
  }

  @override
  bool get shouldEnableDoubleBackToExit => currentIndex == _indexHome;

  @override
  String get backPressMessage => el.tr('common.press_back_again_to_exit');

  @override
  int get currentIndex => _persistentIndex ?? 0;

  @override
  void setIndex(int index) {
    _persistentIndex = index;
    setState(() {});
  }

  @override
  List<CcCurvedNavigationItem> get navigationItems => [
    CcCurvedNavigationItem(
      inactiveIcon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: el.tr(CcLocaleKeys.nav_home),
    ),
    showQuickTestAsSecondTab
        ? CcCurvedNavigationItem(
            inactiveIcon: Icons.bug_report_outlined,
            activeIcon: Icons.bug_report_rounded,
            label: el.tr(CcLocaleKeys.nav_quick_test),
          )
        : CcCurvedNavigationItem(
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

  @override
  bool get enableAppBar => false;

  @override
  bool get enableBottomNavigationBar => !showSplash;

  @override
  PreferredSizeWidget? buildAppBar() => null;

  @override
  Widget? buildBottomNavigationBar() => buildCurvedNavigationBar();

  Widget onBodyWrapper(BuildContext context, Widget body) => body;

  @override
  Widget? buildContent() {
    if (showSplash) {
      return const Center(child: CcLoadingIconWidget());
    }
    return _buildContentForIndex(currentIndex);
  }

  Widget _buildContentForIndex(int index) {
    switch (index) {
      case _indexHome:
        return const HomeTabContent();
      case _indexNotification:
        return showQuickTestAsSecondTab
            ? const QuickTestTabContent()
            : const NotificationTabContent();
      case _indexProfile:
        return const ProfileTabContent();
      default:
        return const HomeTabContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) =>
          onPopInvokedWithResult(context, didPop, result),
      child: Scaffold(
        body: onBodyWrapper(context, SafeArea(child: _body)),
        appBar: enableAppBar ? buildAppBar() : null,
        bottomNavigationBar: enableBottomNavigationBar
            ? buildBottomNavigationBar()
            : null,
      ),
    );
  }

  Widget get _body {
    final content = buildContent() ?? const SizedBox.shrink();
    return FadePageWrapper(child: content);
  }
}
