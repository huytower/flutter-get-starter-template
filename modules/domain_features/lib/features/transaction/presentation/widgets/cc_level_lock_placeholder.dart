import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../budget_limit/presentation/widgets/budget_limit_pie_chart.dart';
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

      double progress = 0;
      List<Widget> tasks = [];

      if (targetLevel == 2) {
        // LV2 requirements: 6 guidelines + 2 streak = 8 points total
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
        // LV3 requirements: 4 streak + 3 fixed budgets + positive cash flow = 8 points total
        final streak = status.reconciliationStreak;
        final budgets = status.fixedBudgetCount;
        final cashFlow = status.hasPositiveCashFlow;

        int points =
            streak.clamp(0, 4) + budgets.clamp(0, 3) + (cashFlow ? 1 : 0);
        progress = (points / 8) * 100;

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

      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(
              context.respPadding(CcPaddingParams.PAGE_MD),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: context.brLg,
                color: context.ccColorScheme.surfaceContainerHighest
                    .withOpacity(0.3),
                border: Border.all(
                  color: context.ccColorScheme.onSurfaceVariant.withOpacity(
                    0.1,
                  ),
                  width: context.respDim(1),
                ),
              ),
              constraints: BoxConstraints(maxWidth: context.respDim(360)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: context.respDim(-28),
                    left: 0,
                    right: 0,
                    child: Center(child: _buildLockIcon(context)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top:
                          context.respDim(28) +
                          context.respPadding(CcPaddingParams.SPACE_MD),
                      bottom: context.respPadding(CcPaddingParams.PAGE_MD),
                      left: context.respPadding(CcPaddingParams.PAGE_MD),
                      right: context.respPadding(CcPaddingParams.PAGE_MD),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildExpProgressArchive(
                          context,
                          progress.toInt(),
                          context.ccColorScheme.primary,
                        ),
                        const CcSpaceXS(),
                        CcFormLabel(
                          text: title,
                          textAlign: TextAlign.center,
                          align: Alignment.center,
                        ),
                        const CcSpaceXS(),
                        CcText(
                          desc,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textStyle: context.ccTextTheme.bodySmall?.copyWith(
                            color: context.ccColorScheme.onSurfaceVariant,
                          ),
                        ),
                        const CcSpaceXS(),
                        ...tasks,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLockIcon(BuildContext context) {
    return Container(
      width: context.respDim(56),
      height: context.respDim(56),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.15),
          width: context.respDim(2),
        ),
      ),
      child: Icon(
        Icons.lock_outline_rounded,
        size: context.respIconSize(baseSize: 24),
        color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context, {
    required String label,
    required bool isCompleted,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.respPadding(2)),
      child: Row(
        children: [
          Icon(
            isCompleted
                ? Icons.check_rounded
                : Icons.radio_button_unchecked_rounded,
            size: context.respIconSize(baseSize: 14),
            color: isCompleted
                ? context.ccColorScheme.primary
                : context.ccColorScheme.onSurfaceVariant.withOpacity(0.4),
          ),
          const CcSpaceXS(),
          Expanded(
            child: CcText(
              label,
              textStyle: context.ccTextTheme.bodySmall?.copyWith(
                color: isCompleted
                    ? context.ccColorScheme.onSurface.withOpacity(0.8)
                    : context.ccColorScheme.onSurfaceVariant.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpProgressArchive(
    BuildContext context,
    int progress,
    Color accent,
  ) {
    final scheme = context.ccColorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CcText(
          el.tr(
            CcLocaleKeys.level_lock_progress_archived,
            namedArgs: {'percent': '$progress'},
          ),
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
        const CcSpaceSM(),
        BudgetLimitPieChart(
          progress: progress.toDouble(),
          color: accent,
          size: context.respDim(20),
        ),
      ],
    );
  }
}
