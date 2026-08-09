import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../loan/presentation/widgets/loan_form.dart';
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
          TabBarView(children: [for (final tab in tabs) _formFor(tab)]),
        ],
      );
    });
  }

  Widget _formFor(TransactionTabKind tab) {
    return switch (tab) {
      TransactionTabKind.expense => const ExpenseForm(),
      TransactionTabKind.income => const IncomeForm(),
      TransactionTabKind.investment => const InvestmentForm(),
      TransactionTabKind.debtLoan => const LoanForm(),
    };
  }
}
