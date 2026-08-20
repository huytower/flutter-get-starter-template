import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/category_entity.dart';

/// Presentation-layer wrapper for [CcCategoryChip], binding it to [CategoryEntity].
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
    return CcCategoryChip(
      labelKey: category.nameKey,
      iconCode: category.iconCode,
      iconFamily: category.iconFamily,
      isEnabled: enabled,
      onTap: onTap,
      accentColor: accentColor,
    );
  }
}
