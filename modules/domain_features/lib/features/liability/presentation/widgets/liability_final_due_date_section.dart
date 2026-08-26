import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/liability_base_form_controller.dart';
import 'liability_date_row.dart';

class LiabilityFinalDueDateSection extends StatelessWidget {
  final LiabilityBaseFormController controller;
  final Color accentColor;

  const LiabilityFinalDueDateSection({
    super.key,
    required this.controller,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CcFormLabel(
          text: el.tr(CcLocaleKeys.transaction_liability_final_due_date_label),
        ),
        const CcSpaceXS(),
        Expanded(
          child: CcBouncing(
            onTap: () => controller.pickFinalDueDate(context),
            borderRadius: context.brMd,
            child: Container(
              height: context.respDim(40),
              padding: EdgeInsets.symmetric(
                horizontal: context.respPadding(CcPaddingParams.SPACE_XS),
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
        CcBouncing(
          onTap: () => controller.setReminderBeforeDueDate(
            !controller.reminderBeforeDueDate.value,
          ),
          child: CcText(
            el.tr(CcLocaleKeys.transaction_liability_reminder_once_label),
            maxLines: 2,
            textStyle: context.ccTextTheme.bodySmall,
          ),
        ),
        const CcSpaceXS(),
        Obx(
          () => Transform.scale(
            scale: 0.7,
            child: CcCheckBox(
              isChecked: controller.reminderBeforeDueDate.value,
              onChanged: (value) => controller.setReminderBeforeDueDate(value),
              checkedColor: accentColor,
              uncheckedBorderColor: context.ccColorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}
