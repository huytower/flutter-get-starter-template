import 'package:auto_route/auto_route.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/export_domain_features.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/data/data_source/color/prj_color.dart';

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
    initNavigationLogic();
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
  double? get navigationBarHeight => 100;

  @override
  bool get shouldEnableDoubleBackToExit => currentIndex == _indexEntry;

  @override
  Color? get navigationActiveColor => PrjColors.primary;

  @override
  Color? get navigationActiveIconColor => PrjColors.onPrimary;

  @override
  Color? get navigationFabColor => PrjColors.primary;

  @override
  String get backPressMessage => el.tr('common.press_back_again_to_exit');

  @override
  int get currentIndex => _persistentIndex ?? _indexEntry;

  @override
  void setIndex(int index) {
    _persistentIndex = index;
    // These tabs derive their figures from transactions that may have been
    // added on the entry tab, so re-fetch each time the tab is (re)opened — the
    // GetX controllers are kept alive, so onReady() won't fire again on its own.
    if (index == _indexWalletAllocation) {
      if (Get.isRegistered<WalletController>()) {
        Get.find<WalletController>().loadWallets();
      }
      if (Get.isRegistered<BudgetLimitController>()) {
        Get.find<BudgetLimitController>().loadBudgets();
      }
    }
    if (index == _indexEntry && Get.isRegistered<TransactionController>()) {
      Get.find<TransactionController>().refreshWalletTotal();
    }
    setState(() {});
  }

  @override
  List<CcCurvedNavigationItem> get navigationItems => [
    CcCurvedNavigationItem(
      inactiveIcon: Icons.pie_chart_outline,
      activeIcon: Icons.pie_chart,
      label: 'BudgetAllocation',
    ),
    // Centre "＋" — opens the Chi/Thu entry form.
    CcCurvedNavigationItem(
      inactiveIcon: Icons.add,
      activeIcon: Icons.add,
      label: el.tr(CcLocaleKeys.nav_transaction),
    ),
    CcCurvedNavigationItem(
      inactiveIcon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: el.tr(CcLocaleKeys.nav_profile),
    ),
  ];

  bool get enableAppBar => false;

  bool get enableBottomNavigationBar => !showSplash;

  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  Widget? buildBottomNavigationBar(BuildContext context) =>
      buildCurvedNavigationBar();

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
        return TransactionPage();
      case _indexProfile:
        return const ProfilePage();
      default:
        return TransactionPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) =>
          onPopInvokedWithResult(context, didPop, result),
      child: Scaffold(
        body: onBodyWrapper(context, SafeArea(child: _buildBody(context))),
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
