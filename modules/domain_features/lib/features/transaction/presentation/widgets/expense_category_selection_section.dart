import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../budget_limit/domain/entities/budget_limit_entity.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../get_x/expense_form_controller.dart';
import '../models/unified_category_item.dart';
import 'base/category_selection_layout.dart';

const String _debugTag = 'ExpenseCategorySelection';

/// Specialized category/budget selector for the Expense tab.
///
/// Merges standard expense categories with user-defined budget limits in a
/// single unified row, with budgets identified by a lightning-bolt icon.
class ExpenseCategorySelectionSection extends StatelessWidget {
  const ExpenseCategorySelectionSection({
    super.key,
    required this.controller,
    required this.activeColor,
  });

  final ExpenseFormController controller;
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

      'state | items=${items.length} '
              'selectedCategoryId=${selectedCategory?.id} '
              'selectedBudgetId=${selectedBudget?.id} '
              'selectedCount=${items.where((i) => _isItemSelected(i, selectedCategory, selectedBudget)).length}'
          .Log(_debugTag);

      return CategorySelectionLayout(
        items: items,
        scrollController: controller.categoryScrollController,
        itemBuilder: (context, index) {
          final item = items[index];
          final key = controller.getItemKey(index);

          final isSelected = _isItemSelected(
            item,
            selectedCategory,
            selectedBudget,
          );

          return UnifiedCategoryItemWidget(
            key: key,
            item: item,
            isSelected: isSelected,
            activeColor: activeColor,
            onTap: () {
              'tap | itemId=${item.id} isBudget=${item.isBudget} '
                      'categoryId=${item.categoryId} budgetId=${item.budgetId} '
                      'wasSelected=$isSelected'
                  .Log(_debugTag);
              if (item.isBudget) {
                final realBudget = controller.budgets
                    .firstWhereOrNull((b) => b.budget.id == item.budgetId)
                    ?.budget;
                if (realBudget != null) {
                  controller.setBudget(realBudget);
                } else {
                  'tap | budget not found for itemId=${item.id} budgetId=${item.budgetId}'
                      .Log(_debugTag);
                }
              } else {
                final cat = controller.getCachedCategoryById(item.categoryId);
                if (cat != null) {
                  controller.setCategory(cat);
                } else {
                  'tap | category not cached for itemId=${item.id} categoryId=${item.categoryId}'
                      .Log(_debugTag);
                }
              }
              'afterTap | selectedCategoryId=${controller.selectedCategory.value?.id} '
                      'selectedBudgetId=${controller.selectedBudget.value?.id}'
                  .Log(_debugTag);
            },
          );
        },
      );
    });
  }

  /// A category that owns a budget is represented in the unified list by its
  /// budget item alone, so that card is the selected one whenever the category
  /// is selected — including the default selection, where the budget may not be
  /// resolved yet.
  bool _isItemSelected(
    UnifiedCategoryItem item,
    CategoryEntity? selectedCategory,
    BudgetLimitEntity? selectedBudget,
  ) {
    final categoryMatches = selectedCategory?.id == item.categoryId;
    if (item.isBudget) {
      return selectedBudget?.id == item.budgetId ||
          (selectedBudget == null && categoryMatches);
    }
    return selectedBudget == null && categoryMatches;
  }
}
