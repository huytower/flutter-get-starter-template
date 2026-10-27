import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../liability/presentation/get_x/liability_base_form_controller.dart';
import '../../../liability/presentation/get_x/liability_form_controller.dart';
import '../../../liability/presentation/get_x/lend_form_controller.dart';
import '../../domain/usecases/create_investment_transaction_usecase.dart';
import '../get_x/investment_form_controller.dart';
import '../get_x/transaction_controller.dart';

class TransactionHeaderActions extends StatelessWidget {
  const TransactionHeaderActions({
    super.key,
    required this.controller,
    this.onSubmit,
    this.onOpenReport,
  });

  final TransactionController controller;
  final VoidCallback? onSubmit;
  final VoidCallback? onOpenReport;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSubmitButton(context),
        const CcSpaceXS(),
        _buildReportButton(context),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedTabIndex.value;
      final tabs = controller.visibleTabs;
      if (selectedIndex < 0 || selectedIndex >= tabs.length) {
        return const SizedBox.shrink();
      }
      final tabKind = tabs[selectedIndex];
      final activeColor = _getTabColor(context, tabKind);
      final icon = _getTabIcon(tabKind);

      return CcIconButton.bouncing(
        onTap: onSubmit ?? () {},
        bgColor: context.ccColorScheme.onPrimary.withAlpha(10),
        height: context.respDim(30),
        width: context.respDim(30),
        icon: Icon(
          icon,
          size: context.respIconSize(baseSize: 22),
          color: activeColor,
        ),
      );
    });
  }

  Widget _buildReportButton(BuildContext context) {
    return CcIconButton.bouncing(
      onTap: onOpenReport ?? () {},
      icon: Icon(
        Icons.bar_chart_rounded,
        size: context.respIconSize(baseSize: 28),
        color: context.ccColorScheme.onPrimary,
      ),
      tooltip: el.tr(CcLocaleKeys.report_title),
    );
  }

  static Color _getTabColor(BuildContext context, TransactionTabKind tab) {
    return switch (tab) {
      TransactionTabKind.expense => context.ccColorScheme.error,
      TransactionTabKind.income => PrjColors.success,
      TransactionTabKind.investment => context.ccColorScheme.investment,
      TransactionTabKind.liability => context.ccColorScheme.liability,
      TransactionTabKind.lend => context.ccColorScheme.liability,
    };
  }

  static IconData _getTabIcon(TransactionTabKind tab) {
    switch (tab) {
      case TransactionTabKind.expense:
        return Icons.arrow_circle_down;
      case TransactionTabKind.income:
        return Icons.arrow_circle_up;
      case TransactionTabKind.investment:
        if (Get.isRegistered<InvestmentFormController>()) {
          final c = Get.find<InvestmentFormController>();
          return c.direction.value == InvestmentDirectionForm.contribute
              ? Icons.arrow_circle_down
              : Icons.arrow_circle_up;
        }
        return Icons.arrow_circle_down;
      case TransactionTabKind.liability:
        if (Get.isRegistered<LiabilityFormController>()) {
          final c = Get.find<LiabilityFormController>();
          return c.action.value == LiabilityDirectionForm.decrease
              ? Icons.arrow_circle_down
              : Icons.arrow_circle_up;
        }
        return Icons.arrow_circle_up;
      case TransactionTabKind.lend:
        if (Get.isRegistered<LendFormController>()) {
          final c = Get.find<LendFormController>();
          return c.action.value == LiabilityDirectionForm.decrease
              ? Icons.arrow_circle_up
              : Icons.arrow_circle_down;
        }
        return Icons.arrow_circle_down;
    }
  }
}
