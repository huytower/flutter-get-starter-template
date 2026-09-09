import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../get_x/liability_base_form_controller.dart';
import '../get_x/liability_form_controller.dart';
import 'liability_date_row.dart';

/// Repeatable due-date + amount row editor for a Trả góp (installment) loan's
/// repayment schedule, driven by [LiabilityBaseFormController.installmentDrafts].
class LiabilityInstallmentScheduleEditor extends StatelessWidget {
  final LiabilityBaseFormController controller;
  final Color activeColor;

  const LiabilityInstallmentScheduleEditor({
    super.key,
    required this.controller,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final drafts = controller.installmentDrafts.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < drafts.length; i++)
            _buildRow(context, i, drafts[i]),
          _buildAddButton(context),
        ],
      );
    });
  }

  Widget _buildRow(
    BuildContext context,
    int index,
    LiabilityInstallmentDraft draft,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: CcBouncing(
                onTap: () => controller.pickInstallmentDueDate(context, index),
                borderRadius: context.brMd,
                child: Container(
                  height: context.respDim(45),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
                    vertical: context.respPadding(CcPaddingParams.SPACE_XS),
                  ),
                  decoration: BoxDecoration(
                    color: context.ccColorScheme.surfaceVariant.withAlpha(80),
                    borderRadius: context.brMd,
                    border: Border.all(
                      color: context.ccColorScheme.outlineVariant.withAlpha(10),
                      width: 0.4,
                    ),
                  ),
                  child: Obx(
                    () => LiabilityDateRow(
                      date: draft.dueDate.value,
                      icon: Icons.calendar_today_outlined,
                      iconColor: activeColor,
                    ),
                  ),
                ),
              ),
          ),
          const CcSpaceXS(),
          Expanded(
            child: CcBouncing(
              onTap: () => controller.showKeypadForInstallment(context, index),
              borderRadius: context.brMd,
              child: Obx(() {
                final isEditingThis =
                    controller.editingInstallmentIndex.value == index;
                final amount = draft.amount.value;
                final isLimitReached =
                    controller.installmentsTotal == controller.principalAmount;

                return Container(
                  height: context.respDim(45),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
                    vertical: context.respPadding(CcPaddingParams.SPACE_XS),
                  ),
                  decoration: BoxDecoration(
                    color: context.ccColorScheme.surfaceVariant.withAlpha(80),
                    borderRadius: context.brMd,
                    border: isEditingThis
                        ? Border.all(color: activeColor, width: 2)
                        : isLimitReached
                        ? Border.all(
                            color: activeColor.withAlpha(100),
                            width: 1.5,
                          )
                        : Border.all(
                            color: context.ccColorScheme.outlineVariant.withAlpha(10),
                            width: 0.4,
                          ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: CcText(
                    amount == 0
                        ? '0'
                        : TransactionFormHelpers.formatAmount(
                            amount.toString(),
                          ),
                    textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: amount > 0
                          ? activeColor
                          : context.ccColorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }),
            ),
          ),
          CcIconButton.bouncing(
            icon: Icon(
              Icons.remove_circle_outline,
              size: context.respIconSize(baseSize: 20),
              color: context.ccColorScheme.error,
            ),
            onTap: () => controller.removeInstallmentPeriod(index),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Obx(() {
      final isEnabled = controller.canAddInstallment;
      final color = isEnabled ? activeColor : context.ccColorScheme.outline;

      return TextButton.icon(
        onPressed: isEnabled ? controller.addInstallmentPeriod : null,
        icon: Icon(
          Icons.add,
          size: context.respIconSize(baseSize: 18),
          color: color,
        ),
        label: CcText(
          el.tr(CcLocaleKeys.transaction_liability_add_period),
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }
}
