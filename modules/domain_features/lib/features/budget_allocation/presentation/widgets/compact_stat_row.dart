import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class CompactStatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const CompactStatRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CcText(
          '$label: ',
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: color.withOpacity(0.7),
          ),
        ),
        CcText(
          value,
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
      ],
    );
  }
}
