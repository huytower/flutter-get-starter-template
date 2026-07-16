import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/category_group_entity.dart';
import 'category_chip.dart';

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
    return Padding(
      padding: EdgeInsets.only(
        top: context.respDim(16),
        bottom: context.respDim(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcSymmetricPadding(
            horizontal: CcPaddingParams.PAGE_SM,
            child: CcText(
              el.tr(group.nameKey),
              textStyle: context.ccTextTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.ccColorScheme.onSurface,
              ),
            ),
          ),
          const CcSpaceSM(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
            ),
            child: Row(
              children: categories.map((cat) {
                final enabled = isEnabled(cat);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    category: cat,
                    enabled: enabled,
                    onTap: () => onToggle(cat),
                    accentColor: accentColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
