import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/money_format_helper.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../budget_limit/domain/entities/budget_insights_entity.dart';
import '../get_x/budget_allocation_controller.dart';

/// Phase 3.4 "AI Actions" panel — pacing/penalty/deficit/anomaly warnings.
/// Renders nothing when there's nothing to flag (see
/// [BudgetInsightsEntity.hasAnything]), matching the spec's "praise smart
/// spending, don't nag" Smart Budgeting philosophy.
class BudgetInsightsSection extends StatelessWidget {
  final BudgetAllocationController controller;

  const BudgetInsightsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final insights = controller.insights.value;
      if (insights == null || !insights.hasAnything) return const SizedBox();

      final scheme = context.ccColorScheme;

      return CcSymmetricPadding(
        horizontal: CcPaddingParams.SPACE_LG,
        vertical: CcPaddingParams.SPACE_SM,
        child: Container(
          padding: EdgeInsets.all(context.respDim(12)),
          decoration: BoxDecoration(
            color: scheme.errorContainer.withOpacity(0.15),
            borderRadius: context.brLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(context),
              const CcSpaceSM(),
              if (insights.isDeficit) _buildDeficitLine(context, insights),
              for (final warning in insights.pacingWarnings)
                _buildPacingLine(context, warning),
              for (final warning in insights.penaltyWarnings)
                _buildPenaltyLine(context, warning),
              if (insights.anomalyCount > 0)
                _buildAnomalyLine(context, insights.anomalyCount),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: context.respIconSize(baseSize: 16),
              color: context.ccColorScheme.error,
            ),
            const CcSpaceXS(),
            CcText(
              el.tr(CcLocaleKeys.budget_insights_title),
              textStyle: context.ccTextTheme.titleSmall?.copyWith(
                fontWeight: CcTypographyParams.bold,
                color: context.ccColorScheme.error,
              ),
            ),
          ],
        ),
        CcInkWell(
          onTap: () => context.router.push(const ReportRoute()),
          child: CcText(
            el.tr(CcLocaleKeys.budget_insights_action_review),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.primary,
              fontWeight: CcTypographyParams.semiBold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLine(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(top: context.respDim(4)),
      child: CcText(
        text,
        maxLines: 2,
        textStyle: context.ccTextTheme.bodySmall?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDeficitLine(BuildContext context, BudgetInsightsEntity i) {
    return _buildLine(
      context,
      el.tr(
        CcLocaleKeys.budget_deficit_warning,
        namedArgs: {'amount': formatVndWithSymbol(i.deficitAmount)},
      ),
    );
  }

  Widget _buildPacingLine(BuildContext context, BudgetPacingWarning w) {
    return _buildLine(
      context,
      el.tr(
        CcLocaleKeys.budget_pacing_hint,
        namedArgs: {
          'name': w.budgetName,
          'days': '${w.daysRemaining}',
          'amount': formatVndWithSymbol(w.suggestedDailySpend),
        },
      ),
    );
  }

  Widget _buildPenaltyLine(BuildContext context, BudgetPenaltyWarning w) {
    return _buildLine(
      context,
      el.tr(
        CcLocaleKeys.budget_penalty_warning,
        namedArgs: {'name': w.budgetName, 'percent': '${w.percentUsed}'},
      ),
    );
  }

  Widget _buildAnomalyLine(BuildContext context, int count) {
    return _buildLine(
      context,
      el.tr(
        CcLocaleKeys.budget_anomaly_hint,
        namedArgs: {'count': '$count'},
      ),
    );
  }
}
