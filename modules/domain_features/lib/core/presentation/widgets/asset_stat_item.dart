import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../helper/transaction_form_helpers.dart';

class AssetStatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

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
        Icon(
          icon,
          size: context.respIconSize(baseSize: 18),
          color: color.withOpacity(0.8),
        ),
        const CcSpaceXS(),
        CcText(
          label,
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant.withAlpha(50),
          ),
        ),
        const Spacer(),
        CcText(
          TransactionFormHelpers.formatShort(value),
          textStyle: context.ccTextTheme.labelLarge?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
