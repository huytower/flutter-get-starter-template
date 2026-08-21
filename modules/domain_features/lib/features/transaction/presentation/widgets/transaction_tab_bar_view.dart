import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../liability/presentation/widgets/liability_form.dart';
import '../get_x/transaction_controller.dart';
import 'expense_form.dart';
import 'income_form.dart';
import 'investment_form.dart';
import 'transaction_tab_bar.dart';

class TransactionTabBarView extends StatelessWidget {
  const TransactionTabBarView({super.key, required this.controller});

  final TransactionController controller;

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
            children: [for (final tab in tabs) _buildPage(context, tab)],
          ),
        ],
      );
    });
  }

  Widget _buildPage(BuildContext context, TransactionTabKind tab) {
    final isUnlocked = controller.isTabUnlocked(tab);
    if (!isUnlocked) return _buildLockedPlaceholder(context, tab);

    return switch (tab) {
      TransactionTabKind.expense => const ExpenseForm(),
      TransactionTabKind.income => const IncomeForm(),
      TransactionTabKind.investment => const InvestmentForm(),
      TransactionTabKind.debtLoan => const LiabilityForm(),
    };
  }

  Widget _buildLockedPlaceholder(BuildContext context, TransactionTabKind tab) {
    final level = (tab == TransactionTabKind.investment) ? 2 : 3;
    final message = el.tr(
      CcLocaleKeys.profile_unlock_at_lv,
      namedArgs: {'level': level.toString()},
    );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_person_rounded,
            size: context.respIconSize(baseSize: 64),
            color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.2),
          ),
          const CcSpaceMD(),
          CcText(
            message,
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.4),
              fontWeight: CcTypographyParams.bold,
            ),
          ),
          const CcSpaceSM(),
          CcText(
            tab.label(context),
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
