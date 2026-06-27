import 'package:flutter/material.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import '../../domain/entities/category_entity.dart';
import 'category_item_widget.dart';

/// A horizontal scrollable list of category items.
class CategoryHorizontalList extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final Function(CategoryEntity)? onCategorySelected;

  const CategoryHorizontalList({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.respDim(100),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
        ),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const CcSpaceLG(),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryItemWidget(
            category: category,
            isSelected: category.id == selectedCategoryId,
            onTap: () => onCategorySelected?.call(category),
          );
        },
      ),
    );
  }
}
