import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/helper/wallet_icon_helper.dart';
import '../../domain/entities/category_entity.dart';

class CategoryChip extends StatelessWidget {
  final CategoryEntity category;
  final bool enabled;
  final VoidCallback onTap;
  final Color? accentColor;

  const CategoryChip({
    super.key,
    required this.category,
    required this.enabled,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = accentColor ?? context.ccColorScheme.primary;
    final chipBg = enabled
        ? primary.withOpacity(0.15)
        : context.ccColorScheme.surfaceContainerHighest;
    final iconColor = enabled
        ? primary
        : context.ccColorScheme.onSurfaceVariant;
    final textColor = enabled
        ? primary
        : context.ccColorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: context.respDim(12),
          vertical: context.respDim(8),
        ),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: context.brXl,
          border: Border.all(
            color: enabled ? primary.withOpacity(0.4) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                enabled
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                key: ValueKey(enabled),
                size: context.respIconSize(baseSize: 16),
                color: iconColor,
              ),
            ),
            SizedBox(width: context.respDim(6)),
            Icon(
              iconDataFromCode(
                category.iconCode,
                fontFamily: category.iconFamily,
              ),
              size: context.respIconSize(baseSize: 14),
              color: iconColor,
            ),
            const CcSpaceXS(),
            CcText(
              el.tr(category.nameKey),
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: enabled ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
