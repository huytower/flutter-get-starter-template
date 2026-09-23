import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class TransactionAutoSaveMessage extends StatelessWidget {
  const TransactionAutoSaveMessage({
    super.key,
    required this.countdown,
    required this.onCancel,
  });

  final int countdown;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('auto_save_message'),
      children: [
        Icon(
          Icons.auto_awesome,
          size: context.respIconSize(baseSize: 18),
          color: context.ccColorScheme.primary,
        ),
        const CcSpaceXS(),
        Expanded(
          child: CcText(
            el.tr(
              CcLocaleKeys.transaction_auto_save_countdown,
              namedArgs: {'countdown': countdown.toString()},
            ),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        CcIconButton.bouncing(
          icon: Icon(
            Icons.close_rounded,
            size: context.respIconSize(baseSize: 16),
            color: context.ccColorScheme.onPrimary.withOpacity(0.8),
          ),
          onTap: onCancel,
          width: context.respDim(24),
          height: context.respDim(24),
        ),
      ],
    );
  }
}
