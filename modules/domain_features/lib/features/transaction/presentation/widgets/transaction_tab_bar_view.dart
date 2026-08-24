import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../guideline/guideline_controller.dart';
import '../../../liability/presentation/widgets/liability_form.dart';
import '../../../liability/presentation/widgets/lend_form.dart';
import '../get_x/transaction_controller.dart';
import 'cc_level_lock_placeholder.dart';
import 'expense_form.dart';
import 'income_form.dart';
import 'investment_form.dart';
import 'transaction_tab_bar.dart';

class TransactionTabBarView extends StatelessWidget {
  const TransactionTabBarView({
    super.key,
    required this.controller,
    required this.tabController,
  });

  final TransactionController controller;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tabs = controller.visibleTabs;
      final selectedIndex = controller.selectedTabIndex.value.clamp(
        0,
        tabs.length - 1,
      );
      final activeColor = tabs[selectedIndex].color(context);
      final topColor = activeColor.withAlpha(5);
      final bottomColor = activeColor.withAlpha(10);

      return Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [topColor, bottomColor],
                ),
              ),
            ),
          ),
          TabBarView(
            controller: tabController,
            children: [for (final tab in tabs) _buildPage(context, tab)],
          ),
        ],
      );
    });
  }

  Widget _buildPage(BuildContext context, TransactionTabKind tab) {
    final isUnlocked = controller.isTabUnlocked(tab);
    if (!isUnlocked) {
      return CcBouncing(
        onTap: () => _showUnlockConditions(context, tab),
        child: CcLevelLockPlaceholder(tab: tab),
      );
    }

    return switch (tab) {
      TransactionTabKind.expense => const ExpenseForm(),
      TransactionTabKind.income => const IncomeForm(),
      TransactionTabKind.investment => const InvestmentForm(),
      TransactionTabKind.liability => const LiabilityForm(),
      TransactionTabKind.lend => const LendForm(),
    };
  }

  void _showUnlockConditions(BuildContext context, TransactionTabKind tab) {
    final guideline = Get.find<GuidelineController>();
    final title = guideline.bannerTitle;
    String desc;
    if (tab == TransactionTabKind.investment) {
      desc = el.tr(CcLocaleKeys.guideline_banner_desc_investment);
    } else {
      desc = el.tr(CcLocaleKeys.guideline_banner_desc_liability);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(el.tr(CcLocaleKeys.guideline_reset_confirm_cancel)),
          ),
        ],
      ),
    );
  }
}
