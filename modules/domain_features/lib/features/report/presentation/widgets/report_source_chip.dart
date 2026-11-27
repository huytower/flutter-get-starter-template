import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// Small tag next to a report transaction's title naming where the money
/// belongs, e.g. the investment position "VCB" behind a "Stock" entry.
class ReportSourceChip extends StatelessWidget {
  const ReportSourceChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
        vertical: context.respPadding(CcPaddingParams.SPACE_XS) / 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: context.brPill,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      // CcText fills the width it is given; this keeps the pill around its label.
      child: IntrinsicWidth(
        child: CcText(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
      ),
    );
  }
}
