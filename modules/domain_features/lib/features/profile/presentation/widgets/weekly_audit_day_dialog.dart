import 'package:flutter/material.dart';

import 'weekly_audit_day_dialog_content.dart';

class WeeklyAuditDayDialog extends StatelessWidget {
  final int currentDay;

  const WeeklyAuditDayDialog({super.key, required this.currentDay});

  static Future<int?> show(BuildContext context, {required int currentDay}) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WeeklyAuditDayDialog(currentDay: currentDay),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WeeklyAuditDayDialogContent(currentDay: currentDay);
  }
}
