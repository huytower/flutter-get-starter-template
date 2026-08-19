import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../get_x/transaction_controller.dart';

extension TransactionTabKindStyle on TransactionTabKind {
  String label(BuildContext context) => switch (this) {
    TransactionTabKind.expense => el.tr(CcLocaleKeys.transaction_expense_slip),
    TransactionTabKind.income => el.tr(CcLocaleKeys.transaction_income_slip),
    TransactionTabKind.investment => el.tr(
      CcLocaleKeys.transaction_investment,
    ),
    TransactionTabKind.debtLoan => el.tr(CcLocaleKeys.transaction_debt),
  };

  Color color(BuildContext context) => switch (this) {
    TransactionTabKind.expense => context.ccColorScheme.error,
    TransactionTabKind.income => PrjColors.success,
    TransactionTabKind.investment => PrjColors.investment,
    TransactionTabKind.debtLoan => PrjColors.debtLoan,
  };
}

class TransactionTabBar extends StatelessWidget {
  const TransactionTabBar({
    super.key,
    required this.controller,
    this.showInvestmentBadge = false,
  });

  final TransactionController controller;
  final bool showInvestmentBadge;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
      ),
      height: context.respDim(40),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: context.brLg,
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withOpacity(0.12),
            blurRadius: context.respDim(12),
            offset: Offset(0, context.respDim(6)),
          ),
        ],
      ),
      padding: EdgeInsets.all(context.respDim(4)),
      child: Obx(() => _buildActualTabBar(context, scheme)),
    );
  }

  Widget _buildActualTabBar(BuildContext context, ColorScheme scheme) {
    final tabs = controller.visibleTabs;
    final selectedIndex = controller.selectedTabIndex.value;
    final activeColor = tabs[selectedIndex.clamp(0, tabs.length - 1)].color(
      context,
    );

    return TabBar(
      onTap: controller.setTabIndex,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      indicator: BoxDecoration(
        color: activeColor.withOpacity(0.08),
        borderRadius: context.brLg,
      ),
      labelColor: activeColor,
      unselectedLabelColor: scheme.onSurfaceVariant,
      labelStyle: context.ccTextTheme.labelMedium?.copyWith(
        fontWeight: CcTypographyParams.bold,
      ),
      labelPadding: EdgeInsets.zero,
      tabs: [
        for (final tab in tabs)
          if (tab == TransactionTabKind.investment && showInvestmentBadge)
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tab.label(context)),
                  const SizedBox(width: 4),
                  CcGuidelineBadge(
                    size: 6,
                    color: PrjColors.investment,
                  ),
                ],
              ),
            )
          else
            Tab(text: tab.label(context)),
      ],
    );
  }
}
