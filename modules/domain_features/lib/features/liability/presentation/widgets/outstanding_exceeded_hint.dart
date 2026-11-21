import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

/// Shown under the amount of a repay / collect that is more than what is
/// still owed (Save stays off meanwhile).
class OutstandingExceededHint extends StatelessWidget {
  const OutstandingExceededHint({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(
        top: context.respPadding(CcPaddingParams.DESC_XS),
        left: context.respPadding(CcPaddingParams.DESC_SM),
        right: context.respPadding(CcPaddingParams.DESC_SM),
      ),
      child: Text(
        el.tr(CcLocaleKeys.transaction_liability_exceeds_outstanding),
        style: context.ccTextTheme.bodySmall?.copyWith(
          color: context.ccColorScheme.error,
        ),
      ),
    );
  }
}
