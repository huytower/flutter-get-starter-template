import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../helper/transaction_form_helpers.dart';

class AssetStatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Widget icon;

  const AssetStatItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CcSpaceXS(),
        SizedBox(
          width: context.respIconSize(baseSize: 24),
          height: context.respIconSize(baseSize: 24),
          child: icon,
        ),
        const CcSpaceMD(),
        CcText(
          label,
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant.withAlpha(90),
          ),
        ),
        const Spacer(),
        CcText(
          TransactionFormHelpers.formatShort(value),
          align: Alignment.center,
          textAlign: TextAlign.center,
          textStyle: context.ccTextTheme.labelLarge?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
