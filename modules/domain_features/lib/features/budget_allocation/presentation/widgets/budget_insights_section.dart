import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/helper/budget_name_helper.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../budget_limit/domain/entities/budget_insights_entity.dart';
import '../get_x/budget_allocation_controller.dart';
import 'budget_insight_card.dart';
import 'budget_insights_see_more_shortcut.dart';

/// Phase 3.4 "AI Actions" panel — pacing/penalty/deficit/anomaly warnings.
/// Applied design pattern: Toast-style banners with grid background.
class BudgetInsightsSection extends StatelessWidget {
  final BudgetAllocationController controller;

  const BudgetInsightsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final insights = controller.insights.value;
      if (insights == null || !insights.hasAnything) return const SizedBox();

      final cards = _buildInsightCards(context, insights);
      if (cards.isEmpty) return const SizedBox();

      final hasMore = cards.length > 4;
      final visibleCards = hasMore ? cards.take(4).toList() : cards;

      return CcSymmetricPadding(
        horizontal: CcPaddingParams.PAGE_SM,
        vertical: CcPaddingParams.SPACE_XS,
        child: Column(
          children: [
            ...visibleCards,
            if (hasMore) ...[
              const CcSpaceXS(),
              const BudgetInsightsSeeMoreShortcut(),
            ],
          ],
        ),
      );
    });
  }

  List<Widget> _buildInsightCards(
    BuildContext context,
    BudgetInsightsEntity insights,
  ) {
    final cards = <Widget>[];

    if (insights.isDeficit) {
      cards.add(
        _buildConvertedInsightCard(
          context,
          title: el.tr(CcLocaleKeys.budget_insights_title),
          rawVndAmount: insights.deficitAmount,
          descriptionBuilder: (formattedAmount) => el.tr(
            CcLocaleKeys.budget_deficit_warning,
            namedArgs: {'amount': formattedAmount},
          ),
          icon: Icons.error_outline_rounded,
          color: context.ccColorScheme.error,
          onTap: () => context.router.push(const ReportRoute()),
        ),
      );
    }

    if (insights.isInflowDebtDriven) {
      cards.add(
        _buildConvertedInsightCard(
          context,
          title: el.tr(CcLocaleKeys.budget_insights_title),
          rawVndAmount: insights.debtInflowAmount,
          descriptionBuilder: (formattedAmount) => el.tr(
            CcLocaleKeys.budget_debt_inflow_warning,
            namedArgs: {
              'percent': '${insights.debtInflowPercent}',
              'amount': formattedAmount,
            },
          ),
          icon: Icons.account_balance_outlined,
          color: context.ccColorScheme.error,
          onTap: () => context.router.push(const ReportRoute()),
        ),
      );
    }

    if (insights.isOutflowDebtDriven) {
      cards.add(
        _buildConvertedInsightCard(
          context,
          title: el.tr(CcLocaleKeys.budget_insights_title),
          rawVndAmount: insights.debtOutflowAmount,
          descriptionBuilder: (formattedAmount) => el.tr(
            CcLocaleKeys.budget_debt_outflow_warning,
            namedArgs: {
              'percent': '${insights.debtOutflowPercent}',
              'amount': formattedAmount,
            },
          ),
          icon: Icons.account_balance_outlined,
          color: PrjColors.info,
          onTap: () => context.router.push(const ReportRoute()),
        ),
      );
    }

    for (final warning in insights.penaltyWarnings) {
      cards.add(
        Builder(
          builder: (context) {
            final name = BudgetNameHelper.getDisplayName(
              name: warning.budgetName,
              categoryNameKey: warning.categoryNameKey,
            );
            return BudgetInsightCard(
              title: name,
              description: el.tr(
                CcLocaleKeys.budget_penalty_warning,
                namedArgs: {'name': name, 'percent': '${warning.percentUsed}'},
              ),
              icon: Icons.warning_amber_rounded,
              color: context.ccColorScheme.error,
              onTap: () => context.router.push(const ReportRoute()),
            );
          },
        ),
      );
    }

    for (final warning in insights.pacingWarnings) {
      cards.add(
        Builder(
          builder: (context) {
            final name = BudgetNameHelper.getDisplayName(
              name: warning.budgetName,
              categoryNameKey: warning.categoryNameKey,
            );
            return _buildConvertedInsightCard(
              context,
              title: name,
              rawVndAmount: warning.suggestedDailySpend,
              descriptionBuilder: (formattedAmount) => el.tr(
                CcLocaleKeys.budget_pacing_hint,
                namedArgs: {
                  'name': name,
                  'days': '${warning.daysRemaining}',
                  'amount': formattedAmount,
                },
              ),
              icon: Icons.info_outline_rounded,
              color: PrjColors.info,
              onTap: () => context.router.push(const ReportRoute()),
            );
          },
        ),
      );
    }

    if (insights.anomalyCount > 0) {
      cards.add(
        BudgetInsightCard(
          title: el.tr(CcLocaleKeys.budget_insights_title),
          description: el.tr(
            CcLocaleKeys.budget_anomaly_hint,
            namedArgs: {'count': '${insights.anomalyCount}'},
          ),
          icon: Icons.auto_awesome_outlined,
          color: PrjColors.info,
          onTap: () => context.router.push(const ReportRoute()),
        ),
      );
    }

    return cards;
  }

  Widget _buildConvertedInsightCard(
    BuildContext context, {
    required String title,
    required int rawVndAmount,
    required String Function(String formattedAmount) descriptionBuilder,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final targetCurrency = controller.walletController.currencyCode.value;

    if (targetCurrency.toUpperCase() == 'VND' || rawVndAmount == 0) {
      final formatted = MoneyFormatter.formatWithSymbol(
        rawVndAmount,
        currencyCode: targetCurrency,
      );
      return BudgetInsightCard(
        title: title,
        description: descriptionBuilder(formatted),
        icon: icon,
        color: color,
        onTap: onTap,
      );
    }

    return FutureBuilder<Result<int, CcFailure>>(
      future: controller.walletController.conversionService.convertAmount(
        amount: rawVndAmount,
        fromCurrency: 'VND',
        toCurrency: targetCurrency,
      ),
      builder: (context, snapshot) {
        final converted =
            snapshot.data?.tryGetSuccess() ?? (rawVndAmount / 25982.5).round();
        final formatted = MoneyFormatter.formatWithSymbol(
          converted,
          currencyCode: targetCurrency,
        );
        return BudgetInsightCard(
          title: title,
          description: descriptionBuilder(formatted),
          icon: icon,
          color: color,
          onTap: onTap,
        );
      },
    );
  }
}
