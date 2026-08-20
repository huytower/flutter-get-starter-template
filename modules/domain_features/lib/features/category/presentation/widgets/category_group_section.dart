import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/category_group_entity.dart';

/// Presentation-layer wrapper for [CcCategoryGroupSection], binding it to
/// [CategoryGroupEntity] and [CategoryEntity].
class CategoryGroupSection extends StatelessWidget {
  final CategoryGroupEntity group;
  final List<CategoryEntity> categories;
  final bool Function(CategoryEntity) isEnabled;
  final void Function(CategoryEntity) onToggle;
  final Color? accentColor;

  const CategoryGroupSection({
    super.key,
    required this.group,
    required this.categories,
    required this.isEnabled,
    required this.onToggle,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return CcCategoryGroupSection(
      items: categories
          .map(
            (c) => CcCategoryGroupItem(
              labelKey: c.nameKey,
              iconCode: c.iconCode,
              iconFamily: c.iconFamily,
              originalData: c,
            ),
          )
          .toList(),
      isEnabled: (item) => isEnabled(item.originalData as CategoryEntity),
      onToggle: (item) => onToggle(item.originalData as CategoryEntity),
      accentColor: accentColor,
    );
  }
}
