import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/liability_base_form_controller.dart';

class LiabilityReminderToggle extends StatelessWidget {
  final LiabilityBaseFormController controller;
  final Color accentColor;
  final String label;

  const LiabilityReminderToggle({
    super.key,
    required this.controller,
    required this.accentColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          Icons.notifications_active_outlined,
          size: context.respIconSize(baseSize: 14),
          color: accentColor,
        ),
        const CcSpaceXS(),
        CcText(label, maxLines: 2, textStyle: context.ccTextTheme.bodySmall),
        const CcSpaceXS(),
        Obx(() {
          return CcBouncing(
            onTap: () => controller.setReminderBeforeDueDate(
              !controller.reminderBeforeDueDate.value,
            ),
            child: CcCheckBox(
              isChecked: controller.reminderBeforeDueDate.value,
              onChanged: (value) => controller.setReminderBeforeDueDate(value),
              checkedColor: accentColor,
              uncheckedBorderColor: context.ccColorScheme.outline,
            ),
          );
        }),
      ],
    );
  }
}
