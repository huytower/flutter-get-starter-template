import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class BudgetLimitLockNotice extends StatelessWidget {
  const BudgetLimitLockNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.lock_clock_outlined,
          size: context.respIconSize(baseSize: 16),
          color: context.ccColorScheme.onSurfaceVariant,
        ),
        const CcSpaceSM(),
        Expanded(
          child: CcText(
            el.tr(CcLocaleKeys.budget_limit_locked),
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
