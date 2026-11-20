import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:domain_features/features/budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import 'package:domain_features/features/budget_allocation/presentation/pages/budget_allocation_page.dart';
import 'package:domain_features/features/budget_limit/presentation/get_x/budget_limit_controller.dart';
import 'package:domain_features/features/guideline/guideline_controller.dart';
import 'package:domain_features/features/guideline/presentation/widgets/prj_guideline_badge.dart';
import 'package:domain_features/features/profile/presentation/pages/profile_page.dart';
import 'package:domain_features/features/profile/user_level/presentation/get_x/user_level_controller.dart';
import 'package:domain_features/features/transaction/presentation/get_x/transaction_controller.dart';
import 'package:domain_features/features/transaction/presentation/pages/transaction_page.dart';
import 'package:domain_features/features/wallet/presentation/get_x/wallet_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../contracts/main_shell_provider.dart';
import '../contracts/main_tab.dart';

@LazySingleton(as: MainShellProvider)
class MainShellProviderImpl implements MainShellProvider {
  /// Badge size on a navigation item, where only the dot is shown.
  static const double _tabBadgeSize = 8;

  @override
  Widget buildTab(MainTab tab) => switch (tab) {
    MainTab.budget => const BudgetAllocationPage(),
    MainTab.entry => const TransactionPage(),
    MainTab.profile => const ProfilePage(),
  };

  @override
  Widget? tabBadge(MainTab tab) {
    final guideline = Get.find<GuidelineController>();
    return guideline.activeTabIndex == tab.index
        ? const PrjGuidelineBadge(size: _tabBadgeSize, forceHideLabel: true)
        : null;
  }

  /// [Obx] also tracks every observable [builder] reads (through [tabBadge]:
  /// guideline progress, user level), not only the bounce trigger.
  @override
  Widget watchTabs(Widget Function() builder) {
    final guideline = Get.find<GuidelineController>();
    return Obx(() {
      final _ = guideline.bounceTrigger.value;
      return builder();
    });
  }

  @override
  Future<void> refreshTab(MainTab tab) async {
    getIt<UserLevelController>().refresh();

    switch (tab) {
      case MainTab.budget:
        if (Get.isRegistered<BudgetAllocationController>()) {
          Get.find<BudgetAllocationController>().loadAll();
        } else {
          if (Get.isRegistered<WalletController>()) {
            Get.find<WalletController>().loadWallets();
          }
          if (Get.isRegistered<BudgetLimitController>()) {
            Get.find<BudgetLimitController>().loadBudgets();
          }
        }
      case MainTab.entry:
        if (Get.isRegistered<TransactionController>()) {
          Get.find<TransactionController>().refreshWalletTotal();
        }
      case MainTab.profile:
        break;
    }
  }
}
