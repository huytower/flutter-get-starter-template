import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/expense_form_controller.dart';
import 'base/category_selection_layout.dart';

/// Specialized category/budget selector for the Expense tab.
///
/// Merges standard expense categories with user-defined budget limits in a
/// single unified row, with budgets identified by a lightning-bolt icon.
class ExpenseCategorySelectionSection extends GetView<ExpenseFormController> {
  const ExpenseCategorySelectionSection({super.key, required this.activeColor});

  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingUnified.value) {
        return const CcCategoryShimmerList();
      }

      final items = controller.unifiedItems;
      final selectedBudget = controller.selectedBudget.value;
      final selectedCategory = controller.selectedCategory.value;

      return CategorySelectionLayout(
        items: items,
        scrollController: controller.categoryScrollController,
        itemBuilder: (context, index) {
          final item = items[index];

          bool isSelected = false;
          if (item.isBudget) {
            isSelected = selectedBudget?.id == item.budgetId;
          } else {
            isSelected =
                selectedBudget == null &&
                selectedCategory?.id == item.categoryId;
          }

          return UnifiedCategoryItemWidget(
            item: item,
            isSelected: isSelected,
            activeColor: activeColor,
            onTap: () {
              if (item.isBudget) {
                final realBudget = controller.budgets
                    .firstWhereOrNull((b) => b.budget.id == item.budgetId)
                    ?.budget;
                if (realBudget != null) {
                  controller.setBudget(realBudget);
                }
              } else {
                final cat = controller.getCachedCategoryById(item.categoryId);
                if (cat != null) {
                  controller.setCategory(cat);
                }
              }
            },
          );
        },
      );
    });
  }
}
