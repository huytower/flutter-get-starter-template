import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/transaction_form_helpers.dart';

class CompactIconStat extends StatelessWidget {
  final IconData icon;
  final int value;
  final bool visible;
  final Color color;

  const CompactIconStat({
    super.key,
    required this.icon,
    required this.value,
    required this.visible,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CcIcon(
          icon: icon,
          size: context.respIconSize(baseSize: 10),
          color: color.withOpacity(0.7),
        ),
        const SizedBox(width: 2),
        CcText(
          visible ? TransactionFormHelpers.formatShort(value) : '***',
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
      ],
    );
  }
}
