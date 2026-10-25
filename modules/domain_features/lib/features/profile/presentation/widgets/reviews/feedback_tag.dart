import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class FeedbackTag extends StatelessWidget {
  const FeedbackTag({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: context.brPill,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_XS),
        ),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.18)
              : scheme.surfaceContainerHighest,
          borderRadius: context.brPill,
          border: Border.all(
            color: selected ? activeColor : scheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CcText(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textStyle: context.ccTextTheme.bodySmall?.copyWith(
                color: selected ? activeColor : scheme.onSurface,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const CcSpaceXS(),
            Icon(
              selected ? Icons.close_rounded : Icons.add_rounded,
              size: context.respIconSize(baseSize: 16),
              color: selected ? activeColor : scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
