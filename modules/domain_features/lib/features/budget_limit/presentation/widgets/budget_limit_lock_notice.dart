import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../domain/entities/budget_limit_lock_reason.dart';

/// Replaces the limit input when the limit cannot be edited, saying why.
class BudgetLimitLockNotice extends StatelessWidget {
  const BudgetLimitLockNotice({super.key, required this.reason});

  final BudgetLimitLockReason reason;

  @override
  Widget build(BuildContext context) {
    final (icon, messageKey) = switch (reason) {
      BudgetLimitLockReason.pastFirstWeek => (
        Icons.lock_clock_outlined,
        PrjLocaleKeys.budget_limit_locked,
      ),
      BudgetLimitLockReason.hasSpending => (
        Icons.lock_outline_rounded,
        PrjLocaleKeys.budget_limit_locked_has_spending,
      ),
    };

    return Row(
      children: [
        Icon(
          icon,
          size: context.respIconSize(baseSize: 16),
          color: context.ccColorScheme.onSurfaceVariant,
        ),
        const CcSpaceSM(),
        Expanded(
          child: CcText(
            el.tr(messageKey),
            maxLines: 3,
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
