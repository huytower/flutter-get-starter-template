import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'weekly_audit_day_content_sheet.dart';

class WeeklyAuditDaySheet extends StatelessWidget {
  final int currentDay;

  const WeeklyAuditDaySheet({super.key, required this.currentDay});

  static Future<int?> show(BuildContext context, {required int currentDay}) {
    return CcAdaptiveBottomSheet.show<int>(
      context: context,
      builder: (context) => WeeklyAuditDaySheet(currentDay: currentDay),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WeeklyAuditDayContentSheet(currentDay: currentDay);
  }
}
