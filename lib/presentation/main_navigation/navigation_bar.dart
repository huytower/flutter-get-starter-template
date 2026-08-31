import 'package:auto_route/auto_route.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/export_domain_features.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import 'logic/navigation_logic_mixin.dart';

/// Main navigation view.
///
/// Layout: Phân bổ · (＋ Giao dịch) · Hồ sơ
/// History is accessible via the action button on the Giao dịch tab.
/// Budget is accessible from the Phân bổ tab ("Xem tất cả"), not a top-level tab.
@RoutePage()
class NavigationBar extends StatefulWidget {
  const NavigationBar({super.key});

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar>
    with CcCurvedNavigationMixin, DoubleBackToExitMixin, NavigationLogicMixin {
  // Navigation indices — entry ("Giao dịch") is centred as the raised "＋".
  static const int _indexWalletAllocation = 0;
  static const int _indexEntry = 1;
  static const int _indexProfile = 2;

  // Singleton to persist index across hot reload.
  static int? _persistentIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  bool handleCustomNavigation() {
    if (currentIndex != _indexEntry) {
      setIndex(_indexEntry);
      return true;
    }
    return false;
  }

  @override
  double? get navigationBarHeight => context.respDim(70);

  @override
  bool get shouldEnableDoubleBackToExit => currentIndex == _indexEntry;

  @override
  Color? get navigationActiveColor => PrjColors.primary;

  @override
  Color? get navigationActiveIconColor => PrjColors.onPrimary;

  @override
  Color? get navigationFabColor => PrjColors.primary;

  @override
  String get backPressMessage =>
      el.tr(CcLocaleKeys.common_press_back_again_to_exit);

  @override
  int get currentIndex => _persistentIndex ?? _indexEntry;

  @override
  void setIndex(int index) {
    _persistentIndex = index;
    handleTabRefresh(index);
    setState(() {});
  }

  @override
  List<CcCurvedNavigationItem> get navigationItems {
    final guideline = Get.find<GuidelineController>();

    return [
      CcCurvedNavigationItem(
        inactiveIcon: Icons.pie_chart_outline,
        activeIcon: Icons.pie_chart,
        label: el.tr(CcLocaleKeys.nav_budget_allocation),
        badgeWidget: guideline.activeTabIndex == 0
            ? CcGuidelineBadge(
                size: 8,
                color: guideline.currentColor,
                bounceTrigger: guideline.bounceTrigger,
                forceHideLabel: true,
              )
            : null,
      ),
      // Centre "＋" — opens the Chi/Thu entry form.
      CcCurvedNavigationItem(
        inactiveIcon: Icons.add,
        activeIcon: Icons.add,
        label: el.tr(CcLocaleKeys.nav_transaction),
        badgeWidget: guideline.activeTabIndex == 1
            ? CcGuidelineBadge(
                size: 8,
                color: guideline.currentColor,
                bounceTrigger: guideline.bounceTrigger,
                forceHideLabel: true,
              )
            : null,
      ),
      CcCurvedNavigationItem(
        inactiveIcon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: el.tr(CcLocaleKeys.nav_profile),
        badgeWidget: guideline.activeTabIndex == 2
            ? CcGuidelineBadge(
                size: 8,
                color: guideline.currentColor,
                bounceTrigger: guideline.bounceTrigger,
                forceHideLabel: true,
              )
            : null,
      ),
    ];
  }

  bool get enableAppBar => false;

  bool get enableBottomNavigationBar => !showSplash;

  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  Widget? buildBottomNavigationBar(BuildContext context) {
    final guideline = Get.find<GuidelineController>();
    final systemBottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final _ = guideline.bounceTrigger.value;

      // To support both gesture navigation and 3-button navigation without
      // overlap, we use the actual system bottom padding.
      // The background container ensures the color extends behind the system bar.
      return Container(
        color: isDark ? Colors.transparent : CcBaseColors.white100,
        child: Padding(
          padding: EdgeInsets.only(bottom: systemBottomPadding),
          child: buildCurvedNavigationBar(),
        ),
      );
    });
  }

  Widget onBodyWrapper(BuildContext context, Widget body) => body;

  Widget? buildContent(BuildContext context) {
    if (showSplash) {
      return const Center(child: CcLoadingIconWidget());
    }
    return _buildContentForIndex(currentIndex);
  }

  Widget? _buildContentForIndex(int index) {
    switch (index) {
      case _indexWalletAllocation:
        return const BudgetAllocationPage();
      case _indexEntry:
        return const TransactionPage();
      case _indexProfile:
        return const ProfilePage();
      default:
        return const TransactionPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) =>
          onPopInvokedWithResult(context, didPop, result),
      child: Scaffold(
        // Remove SafeArea here to allow individual pages to manage their own
        // safe area (e.g. for immersive gradient headers that span into the
        // status bar). Pages using CcViewConfigMixin (default) still get a
        // SafeArea wrapper by default unless they override useSafeArea.
        body: onBodyWrapper(context, _buildBody(context)),
        appBar: enableAppBar ? buildAppBar(context) : null,
        bottomNavigationBar: enableBottomNavigationBar
            ? buildBottomNavigationBar(context)
            : null,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final content = buildContent(context) ?? const SizedBox.shrink();
    return FadePageWrapper(child: content);
  }
}
