import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../get_x/loan_form_controller.dart';
import 'loan_date_row.dart';

/// Repeatable due-date + amount row editor for a Trả góp (installment) loan's
/// repayment schedule, driven by [LoanFormController.installmentDrafts].
class LoanInstallmentScheduleEditor extends StatelessWidget {
  final LoanFormController controller;
  final Color activeColor;

  const LoanInstallmentScheduleEditor({
    super.key,
    required this.controller,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < controller.installmentDrafts.length; i++)
            _buildRow(context, i, controller.installmentDrafts[i]),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    int index,
    LoanInstallmentDraft draft,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CcInkWell(
              onTap: () => controller.pickInstallmentDueDate(context, index),
              borderRadius: context.brMd,
              child: Container(
                height: context.respDim(48),
                padding: EdgeInsets.symmetric(
                  horizontal: context.respPadding(12),
                ),
                decoration: BoxDecoration(
                  color: context.ccColorScheme.onSurface.withAlpha(10),
                  borderRadius: context.brMd,
                ),
                child: Obx(
                  () => LoanDateRow(
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
            child: CcInkWell(
              onTap: () => controller.showKeypadForInstallment(context, index),
              borderRadius: context.brMd,
              child: Obx(() {
                final isEditingThis =
                    controller.editingInstallmentIndex.value == index;
                final amount = draft.amount.value;

                return Container(
                  height: context.respDim(48),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.respPadding(12),
                  ),
                  decoration: BoxDecoration(
                    color: context.ccColorScheme.onSurface.withAlpha(10),
                    borderRadius: context.brMd,
                    border: isEditingThis
                        ? Border.all(color: activeColor, width: 2)
                        : null,
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
    return TextButton.icon(
      onPressed: controller.addInstallmentPeriod,
      icon: Icon(
        Icons.add,
        size: context.respIconSize(baseSize: 18),
        color: activeColor,
      ),
      label: CcText(
        el.tr(CcLocaleKeys.transaction_loan_add_period),
        textStyle: context.ccTextTheme.labelMedium?.copyWith(
          color: activeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
