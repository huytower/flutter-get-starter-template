import 'package:flutter/material.dart';

import 'weekly_audit_day_content_sheet.dart';

class WeeklyAuditDaySheet extends StatelessWidget {
  final int currentDay;

  const WeeklyAuditDaySheet({super.key, required this.currentDay});

  static Future<int?> show(BuildContext context, {required int currentDay}) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WeeklyAuditDaySheet(currentDay: currentDay),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WeeklyAuditDaySheetContent(currentDay: currentDay);
  }
}
