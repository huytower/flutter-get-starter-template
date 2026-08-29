import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class InvestPeriodIndicator extends StatelessWidget {
  final int month;
  final Color color;

  const InvestPeriodIndicator({
    super.key,
    required this.month,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(6),
        vertical: context.respPadding(2),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CcText(
        el.tr(CcLocaleKeys.budget_month_indicator, args: [month.toString()]),
        textStyle: context.ccTextTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
