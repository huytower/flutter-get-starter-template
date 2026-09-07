import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/income_form_controller.dart';
import 'base/category_selection_layout.dart';

/// Specialized category selector for the Income tab.
///
/// Shows only standard income categories, sorted by most-recent activity.
/// Decoupled from the budget-limit logic used in the Expense tab.
class IncomeCategorySelectionSection extends GetView<IncomeFormController> {
  const IncomeCategorySelectionSection({super.key, required this.activeColor});

  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingUnified.value) {
        return const CcCategoryShimmerList();
      }

      final items = controller.unifiedItems;
      final selectedCategory = controller.selectedCategory.value;

      return CategorySelectionLayout(
        items: items,
        scrollController: controller.categoryScrollController,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedCategory?.id == item.categoryId;

          return UnifiedCategoryItemWidget(
            item: item,
            isSelected: isSelected,
            activeColor: activeColor,
            onTap: () {
              final cat = controller.getCachedCategoryById(item.categoryId);
              if (cat != null) {
                controller.setCategory(cat);
              }
            },
          );
        },
      );
    });
  }
}
