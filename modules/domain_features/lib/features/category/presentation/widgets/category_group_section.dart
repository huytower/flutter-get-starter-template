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
    return Column(
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
        HorizontalFadeScrollView(
          height: context.respDim(30),
          builder: (controller) => ListView.builder(
            controller: controller,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
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
            },
          ),
        ),
        const CcSpaceSM(),
      ],
    );
  }
}
