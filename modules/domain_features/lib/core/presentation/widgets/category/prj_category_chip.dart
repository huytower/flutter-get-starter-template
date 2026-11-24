import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// A horizontal chip representing a category with an icon and label.
/// Supports an 'enabled' (selected) state with glassy highlights.
///
/// [label] is shown as is — pass already-translated text.
class PrjCategoryChip extends StatelessWidget {
  final String label;
  final int iconCode;
  final String? iconFamily;
  final bool hasEnabled;
  final VoidCallback onTap;
  final Color? accentColor;

  const PrjCategoryChip({
    super.key,
    required this.label,
    required this.iconCode,
    this.iconFamily,
    required this.hasEnabled,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = accentColor ?? context.ccColorScheme.primary;
    final chipBackground = hasEnabled
        ? primary.withValues(alpha: 0.15)
        : context.ccColorScheme.surfaceContainerHighest;
    final iconColor = hasEnabled
        ? primary
        : context.ccColorScheme.onSurfaceVariant;
    final textColor = hasEnabled
        ? primary
        : context.ccColorScheme.onSurfaceVariant;

    return CcBouncing(
      onTap: onTap,
      borderRadius: context.brXl,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: context.respDim(12),
          vertical: context.respDim(8),
        ),
        decoration: BoxDecoration(
          color: chipBackground,
          borderRadius: context.brXl,
          border: Border.all(
            color: hasEnabled
                ? primary.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                hasEnabled
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                key: ValueKey(hasEnabled),
                size: context.respIconSize(baseSize: 16),
                color: iconColor,
              ),
            ),
            SizedBox(width: context.respDim(6)),
            Icon(
              iconDataFromCode(iconCode, fontFamily: iconFamily),
              size: context.respIconSize(baseSize: 14),
              color: iconColor,
            ),
            const CcSpaceXS(),
            CcText(
              label,
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: hasEnabled
                    ? CcTypographyParams.semiBold
                    : CcTypographyParams.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
