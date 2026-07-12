import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:cc_sdk_ui/widgets/padding/cc_padding.dart';
import 'package:flutter/material.dart';

class TransactionSeeMoreSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const TransactionSeeMoreSection({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              CcText(
                'Xem thêm', // Consider localizing this if a key exists
                textStyle: context.ccTextTheme.labelMedium?.copyWith(
                  color: Colors.grey[700],
                  fontSize: context.respFontSize(13),
                ),
              ),
              const CcSpaceXS(),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        if (isExpanded) CcPadding(child, 0, 0, 0, CcPaddingParams.DESC_SM),
      ],
    );
  }
}
