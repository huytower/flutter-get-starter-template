import 'package:flutter/material.dart';

import '../../../../core/helper/adaptive_bottom_sheet.dart';
import 'weekly_audit_day_content_sheet.dart';

class WeeklyAuditDaySheet extends StatelessWidget {
  final int currentDay;

  const WeeklyAuditDaySheet({super.key, required this.currentDay});

  static Future<int?> show(BuildContext context, {required int currentDay}) {
    return showAdaptiveBottomSheet<int>(
      context: context,
      builder: (context) => WeeklyAuditDaySheet(currentDay: currentDay),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WeeklyAuditDayContentSheet(currentDay: currentDay);
  }
}
