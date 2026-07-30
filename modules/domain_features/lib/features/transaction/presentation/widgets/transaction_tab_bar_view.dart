import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../get_x/transaction_controller.dart';
import 'expense_form.dart';
import 'income_form.dart';

class TransactionTabBarView extends StatelessWidget {
  const TransactionTabBarView({super.key, required this.controller});

  final TransactionController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedTabIndex.value;
      final activeColor = _getTabColor(context, selectedIndex);
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
          const TabBarView(children: [ExpenseForm(), IncomeForm()]),
        ],
      );
    });
  }

  Color _getTabColor(BuildContext context, int index) {
    return switch (index) {
      0 => context.ccColorScheme.error,
      1 => context.ccColorScheme.primary,
      _ => PrjColors.success,
    };
  }
}
