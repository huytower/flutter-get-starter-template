import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/navigation/domain_router.gr.dart';

class ReportDailyDetailShortcut extends StatelessWidget {
  const ReportDailyDetailShortcut({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? context.ccTextTheme.titleSmall?.color;
    final iconColor = color ?? context.ccColorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        CcBouncing(
          onTap: () => context.router.push(const ReportDailyDetailRoute()),
          child: CcText(
            el.tr(CcLocaleKeys.report_daily_detail),
            textStyle: context.ccTextTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const CcSpaceXS(),
        Icon(
          Icons.chevron_right_rounded,
          size: context.respIconSize(baseSize: 20),
          color: iconColor,
        ),
      ],
    );
  }
}
