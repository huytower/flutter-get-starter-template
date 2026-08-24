import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/liability_entity.dart';
import '../get_x/liability_base_form_controller.dart';
import 'liability_date_row.dart';
import 'liability_installment_schedule_editor.dart';
import 'liability_pill_toggle.dart';

/// Repayment/collection method picker on [LiabilityForm]: installment vs.
/// lump-sum toggle, the matching schedule editor (per-installment dates or a
/// single final due date), and the due-date reminder checkbox.
class LiabilityRepaymentMethodSection extends StatelessWidget {
  final LiabilityBaseFormController controller;
  final Color accentColor;

  const LiabilityRepaymentMethodSection({
    super.key,
    required this.controller,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isBorrowSide = controller.direction == LiabilityDirection.borrow;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CcFormLabel(
                text: isBorrowSide
                    ? el.tr(
                        CcLocaleKeys.transaction_loan_repayment_method_label,
                      )
                    : el.tr(
                        CcLocaleKeys.transaction_loan_collection_method_label,
                      ),
              ),
              const CcSpaceXS(),
              Expanded(
                child: LiabilityPillToggle(
                  selectedIndex:
                      controller.repaymentMethod.value ==
                          LiabilityRepaymentMethod.installment
                      ? 0
                      : 1,
                  firstLabel: isBorrowSide
                      ? el.tr(CcLocaleKeys.transaction_loan_method_installment)
                      : el.tr(
                          CcLocaleKeys.transaction_loan_method_installment_lend,
                        ),
                  secondLabel: isBorrowSide
                      ? el.tr(CcLocaleKeys.transaction_loan_method_lump_sum)
                      : el.tr(
                          CcLocaleKeys.transaction_loan_method_lump_sum_lend,
                        ),
                  activeColor: accentColor,
                  onChanged: (index) => controller.setRepaymentMethod(
                    index == 0
                        ? LiabilityRepaymentMethod.installment
                        : LiabilityRepaymentMethod.lumpSum,
                  ),
                ),
              ),
            ],
          ),
          const CcSpaceSM(),
          if (controller.repaymentMethod.value ==
              LiabilityRepaymentMethod.installment)
            _InstallmentSchedule(
              controller: controller,
              accentColor: accentColor,
            )
          else
            _FinalDueDate(controller: controller, accentColor: accentColor),
        ],
      );
    });
  }
}

class _InstallmentSchedule extends StatelessWidget {
  final LiabilityBaseFormController controller;
  final Color accentColor;

  const _InstallmentSchedule({
    required this.controller,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isBorrowSide = controller.direction == LiabilityDirection.borrow;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(
          text: isBorrowSide
              ? el.tr(CcLocaleKeys.transaction_loan_schedule_label)
              : el.tr(CcLocaleKeys.transaction_loan_schedule_lend_label),
        ),
        const CcSpaceXS(),
        LiabilityInstallmentScheduleEditor(
          controller: controller,
          activeColor: accentColor,
        ),
        const CcSpaceSM(),
        _ReminderToggle(
          controller: controller,
          accentColor: accentColor,
          label: el.tr(CcLocaleKeys.transaction_loan_reminder_recurring_label),
        ),
      ],
    );
  }
}

class _FinalDueDate extends StatelessWidget {
  final LiabilityBaseFormController controller;
  final Color accentColor;

  const _FinalDueDate({required this.controller, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CcFormLabel(
          text: el.tr(CcLocaleKeys.transaction_loan_final_due_date_label),
        ),
        const CcSpaceXS(),
        Expanded(
          child: CcInkWell(
            onTap: () => controller.pickFinalDueDate(context),
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
                () => LiabilityDateRow(
                  date: controller.finalDueDate.value,
                  icon: Icons.event_outlined,
                  iconSize: 18,
                  iconColor: accentColor,
                ),
              ),
            ),
          ),
        ),
        const CcSpaceXS(),
        Icon(
          Icons.notifications_active_outlined,
          size: context.respIconSize(baseSize: 18),
          color: accentColor,
        ),
        const CcSpaceXS(),
        Expanded(
          child: CcInkWell(
            onTap: () => controller.setReminderBeforeDueDate(
              !controller.reminderBeforeDueDate.value,
            ),
            child: CcText(
              el.tr(CcLocaleKeys.transaction_loan_reminder_once_label),
              textStyle: context.ccTextTheme.bodyMedium,
            ),
          ),
        ),
        Obx(
          () => SizedBox(
            width: context.respDim(20),
            height: context.respDim(20),
            child: Checkbox(
              value: controller.reminderBeforeDueDate.value,
              onChanged: (value) =>
                  controller.setReminderBeforeDueDate(value ?? false),
              activeColor: accentColor,
              side: BorderSide(color: context.ccColorScheme.outline),
              shape: RoundedRectangleBorder(borderRadius: context.brXs),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReminderToggle extends StatelessWidget {
  final LiabilityBaseFormController controller;
  final Color accentColor;
  final String label;

  const _ReminderToggle({
    required this.controller,
    required this.accentColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CcInkWell(
        onTap: () => controller.setReminderBeforeDueDate(
          !controller.reminderBeforeDueDate.value,
        ),
        child: Row(
          children: [
            Icon(
              Icons.notifications_active_outlined,
              size: context.respIconSize(baseSize: 18),
              color: accentColor,
            ),
            const CcSpaceXS(),
            Expanded(
              child: CcText(label, textStyle: context.ccTextTheme.bodyMedium),
            ),
            SizedBox(
              width: context.respDim(20),
              height: context.respDim(20),
              child: Checkbox(
                value: controller.reminderBeforeDueDate.value,
                onChanged: (value) =>
                    controller.setReminderBeforeDueDate(value ?? false),
                activeColor: accentColor,
                side: BorderSide(color: context.ccColorScheme.outline),
                shape: RoundedRectangleBorder(borderRadius: context.brXs),
              ),
            ),
          ],
        ),
      );
    });
  }
}
