import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../domain/entities/category_entity.dart';

/// A widget representing a single category item.
///
/// Displays an icon in a circular background and the category name below.
class CategoryItemWidget extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryItemWidget({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CcInteractBtnWrapper(
      onTap: onTap ?? () {},
      useDebounce: false,
      isBouncing: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(context),
          const CcSpaceSM(),
          _buildLabel(context),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final double size = context.respDim(60);
    final double iconSize = context.respIconSize(baseSize: 24);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected
            ? context.ccColorScheme.primaryContainer
            : category.color ?? context.ccColorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: context.ccColorScheme.primary, width: 2)
            : null,
      ),
      child: Center(
        child: CcIcon(
          icon: IconData(
            category.iconCode,
            fontFamily: category.iconFamily ?? 'MaterialIcons',
          ),
          size: iconSize,
          color: isSelected
              ? context.ccColorScheme.primary
              : context.ccColorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    return CcText(
      el.tr(category.nameKey),
      textStyle: context.ccTextTheme.bodySmall?.copyWith(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? context.ccColorScheme.primary
            : context.ccColorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
