import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../domain/entities/liability_entity.dart';
import '../get_x/liability_base_form_controller.dart';
import 'liability_installment_schedule_editor.dart';
import 'liability_reminder_toggle.dart';

class LiabilityInstallmentScheduleSection extends StatelessWidget {
  final LiabilityBaseFormController controller;
  final Color accentColor;

  const LiabilityInstallmentScheduleSection({
    super.key,
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
              ? el.tr(CcLocaleKeys.transaction_liability_schedule_label)
              : el.tr(CcLocaleKeys.transaction_liability_schedule_lend_label),
        ),
        const CcSpaceXS(),
        LiabilityInstallmentScheduleEditor(
          controller: controller,
          activeColor: accentColor,
        ),
        const CcSpaceSM(),
        LiabilityReminderToggle(
          controller: controller,
          accentColor: accentColor,
          label: el.tr(
            CcLocaleKeys.transaction_liability_reminder_recurring_label,
          ),
        ),
      ],
    );
  }
}
