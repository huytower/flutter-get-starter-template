import 'package:auto_route/auto_route.dart';
import 'package:bridge/export_bridge.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:message/export_message.dart';
import 'package:theme/export_theme.dart';

import 'logic/navigation_logic_mixin.dart';

/// Main navigation view.
///
/// Layout: Phân bổ · (＋ Giao dịch) · Hồ sơ
/// History is accessible via the action button on the Giao dịch tab.
/// Budget is accessible from the Phân bổ tab ("Xem tất cả"), not a top-level tab.
///
/// Bottom bar or side rail by window size comes from
/// [CcAdaptiveNavigationScaffold]; this view only supplies the app's tabs,
/// splash, double back to exit and system bar style.
@RoutePage()
class NavigationBar extends StatefulWidget {
  const NavigationBar({super.key});

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar>
    with CcDoubleBackToExitMixin, NavigationLogicMixin {
  // Bar index i is MainTab.values[i]; entry ("Giao dịch") is centred as the
  // raised "＋".
  static final int _indexEntry = MainTab.entry.index;

  // Singleton to persist index across hot reload.
  static int? _persistentIndex;

  int get _currentIndex => _persistentIndex ?? _indexEntry;

  void _setIndex(int index) {
    _persistentIndex = index;
    handleTabRefresh(index);
    setState(() {});
  }

  @override
  bool handleCustomNavigation() {
    if (_currentIndex != _indexEntry) {
      _setIndex(_indexEntry);
      return true;
    }
    return false;
  }

  @override
  bool get shouldEnableDoubleBackToExit => _currentIndex == _indexEntry;

  @override
  String get backPressMessage =>
      el.tr(PrjLocaleKeys.common_press_back_again_to_exit);

  @override
  void showBackPressHint(BuildContext context, String message) =>
      showDoubleBackPressSnackBar(context, message);

  List<CcCurvedNavigationItem> get _destinations => [
    CcCurvedNavigationItem(
      inactiveIcon: Icons.pie_chart_outline,
      activeIcon: Icons.pie_chart,
      label: el.tr(PrjLocaleKeys.nav_budget_allocation),
      badgeWidget: mainShell.tabBadge(MainTab.budget),
    ),
    // Centre "＋" — opens the Chi/Thu entry form.
    CcCurvedNavigationItem(
      inactiveIcon: Icons.add,
      activeIcon: Icons.add,
      label: el.tr(PrjLocaleKeys.nav_transaction),
      badgeWidget: mainShell.tabBadge(MainTab.entry),
    ),
    CcCurvedNavigationItem(
      inactiveIcon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: el.tr(PrjLocaleKeys.nav_profile),
      badgeWidget: mainShell.tabBadge(MainTab.profile),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hasDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = context.ccColorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (hasDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: CcBaseColors.transparent,
            systemNavigationBarColor: scheme.background,
            systemNavigationBarIconBrightness: hasDark
                ? Brightness.light
                : Brightness.dark,
          ),
      child: PopScope(
        canPop: canPop,
        onPopInvokedWithResult: (didPop, result) =>
            onPopInvokedWithResult(context, didPop, result),
        // No SafeArea here: pages manage their own (e.g. immersive gradient
        // headers that run under the status bar).
        //
        // The destinations read the tab badges, so they are built inside
        // watchTabs and the shell rebuilds when a badge changes. The page
        // keeps its state across that rebuild (the scaffold keys it).
        child: mainShell.watchTabs(
          () => CcAdaptiveNavigationScaffold(
            destinations: _destinations,
            currentIndex: _currentIndex,
            onSelect: _setIndex,
            primaryIndex: _indexEntry,
            hasNavigation: !showSplash,
            activeColor: PrjColors.primary,
            activeIconColor: PrjColors.onPrimary,
            fabColor: PrjColors.primary,
            barHeight: context.respDim(64),
            body: CcFadePageWrapper(child: _buildContent()),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (showSplash) return const Center(child: CcLoadingIconWidget());
    return mainShell.buildTab(MainTab.fromIndex(_currentIndex));
  }
}
