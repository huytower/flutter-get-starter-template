import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/wallet_icon_helper.dart';
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
    final primary = accentColor ?? context.ccColorScheme.primary;
    final bgIcon = categories.isNotEmpty
        ? iconDataFromCode(
            categories.first.iconCode,
            fontFamily: categories.first.iconFamily,
          )
        : Icons.category_rounded;

    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_SM,
      vertical: CcPaddingParams.SPACE_XS,
      child: ClipRRect(
        borderRadius: context.brXl,
        child: Stack(
          children: [
            // Tinted Background
            Positioned.fill(child: Container(color: primary.withOpacity(0.08))),
            // Watermark Icon
            Positioned(
              right: -context.respDim(20),
              bottom: -context.respDim(20),
              child: Icon(
                bgIcon,
                size: context.respDim(120),
                color: primary.withOpacity(0.1),
              ),
            ),
            // Horizontal Content
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.respDim(18)),
              child: HorizontalFadeScrollView(
                height: context.respDim(45),
                builder: (controller) => ListView.separated(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
                  ),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const CcSpaceSM(),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final enabled = isEnabled(cat);
                    return CategoryChip(
                      category: cat,
                      enabled: enabled,
                      onTap: () => onToggle(cat),
                      accentColor: accentColor,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
