import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../get_x/transaction_controller.dart';

class CcLevelLockPlaceholder extends StatelessWidget {
  final TransactionTabKind tab;

  const CcLevelLockPlaceholder({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    final userLevel = getIt<UserLevelController>();
    final guideline = getIt<GuidelineController>();

    return Obx(() {
      final status = userLevel.status.value;
      final targetLevel = (tab == TransactionTabKind.investment) ? 2 : 3;

      // Calculate progress percentage
      double progress = 0;
      List<Widget> tasks = [];

      if (targetLevel == 2) {
        // LV2 requirements: 6 guidelines + 2 streak
        final completedG = status.completedGuidelineCount;
        final streak = status.reconciliationStreak;
        progress = ((completedG.clamp(0, 6) + streak.clamp(0, 2)) / 8) * 100;

        tasks = [
          _buildTaskItem(
            context,
            label: el.tr(CcLocaleKeys.level_lock_task_setup_budget),
            isCompleted: guideline.isTaskCompleted('budget_limit'),
          ),
          _buildTaskItem(
            context,
            label: el.tr(CcLocaleKeys.level_lock_task_record_transactions),
            isCompleted: guideline.isTaskCompleted('first_transaction'),
          ),
          _buildTaskItem(
            context,
            label: el.tr(CcLocaleKeys.level_lock_task_setup_birth_year),
            isCompleted: guideline.isTaskCompleted('birth_year'),
          ),
          _buildTaskItem(
            context,
            label: el.tr(
              CcLocaleKeys.level_lock_task_reconciliation_streak,
              namedArgs: {'current': streak.toString(), 'total': '2'},
            ),
            isCompleted: streak >= 2,
          ),
        ];
      } else {
        // LV3 requirements: 4 streak + 3 fixed budgets + positive cash flow
        final streak = status.reconciliationStreak;
        final budgets = status.fixedBudgetCount;
        final cashFlow = status.hasPositiveCashFlow;

        int score = 0;
        if (streak >= 4)
          score += 2;
        else if (streak > 0)
          score += 1;
        if (budgets >= 3)
          score += 2;
        else if (budgets > 0)
          score += 1;
        if (cashFlow) score += 1;

        progress = (score / 5) * 100;

        tasks = [
          _buildTaskItem(
            context,
            label: el.tr(
              CcLocaleKeys.level_lock_task_reconciliation_streak,
              namedArgs: {'current': streak.toString(), 'total': '4'},
            ),
            isCompleted: streak >= 4,
          ),
          _buildTaskItem(
            context,
            label: el.tr(
              CcLocaleKeys.level_lock_task_fixed_budgets,
              namedArgs: {'current': budgets.toString(), 'total': '3'},
            ),
            isCompleted: budgets >= 3,
          ),
          _buildTaskItem(
            context,
            label: el.tr(CcLocaleKeys.level_lock_task_positive_cash_flow),
            isCompleted: cashFlow,
          ),
        ];
      }

      final title = (tab == TransactionTabKind.investment)
          ? el.tr(CcLocaleKeys.level_lock_investment_title)
          : el.tr(CcLocaleKeys.level_lock_liability_title);

      final desc = (tab == TransactionTabKind.investment)
          ? el.tr(CcLocaleKeys.level_lock_investment_desc)
          : el.tr(CcLocaleKeys.level_lock_liability_desc);

      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_XL),
          ),
          child: Column(
            children: [
              const CcSpaceXL(),
              _buildLockIcon(context),
              const CcSpaceXL(),
              _buildProgressHeader(context, targetLevel, progress.toInt()),
              const CcSpaceSM(),
              CcText(
                title,
                textStyle: context.ccTextTheme.titleLarge?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                  color: context.ccColorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const CcSpaceMD(),
              CcText(
                desc,
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const CcSpaceXL(),
              ...tasks,
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLockIcon(BuildContext context) {
    return Container(
      width: context.respDim(80),
      height: context.respDim(80),
      decoration: BoxDecoration(
        color: context.ccColorScheme.onSurface.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.lock_outline_rounded,
        size: context.respIconSize(baseSize: 32),
        color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, int level, int progress) {
    final remaining = 100 - progress;
    final text =
        "${el.tr(CcLocaleKeys.level_lock_unlock_at_lv, namedArgs: {'level': level.toString()})} • ${el.tr(CcLocaleKeys.level_lock_remaining_percent, namedArgs: {'percent': remaining.toString()})}";

    return CcText(
      text.toUpperCase(),
      textStyle: context.ccTextTheme.labelMedium?.copyWith(
        fontWeight: CcTypographyParams.bold,
        color: context.ccColorScheme.onSurfaceVariant,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context, {
    required String label,
    required bool isCompleted,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.respPadding(CcPaddingParams.SPACE_SM),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted
                ? Icons.check_rounded
                : Icons.radio_button_unchecked_rounded,
            size: context.respIconSize(baseSize: 20),
            color: isCompleted
                ? context.ccColorScheme.primary
                : context.ccColorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const CcSpaceMD(),
          Expanded(
            child: CcText(
              label,
              textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                color: isCompleted
                    ? context.ccColorScheme.onSurface
                    : context.ccColorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
