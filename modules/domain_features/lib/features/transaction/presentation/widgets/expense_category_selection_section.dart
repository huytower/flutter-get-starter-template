import 'package:domain_features/core/domain/entities/category_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../budget_limit/domain/entities/budget_limit_entity.dart';
import '../../../category/presentation/pages/category_settings_page.dart';
import '../get_x/expense_form_controller.dart';
import '../models/unified_category_item.dart';
import 'base/category_selection_layout.dart';
import 'base/unified_category_item_widget.dart';

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
      final items = controller.unifiedItems;
      final selectedBudget = controller.selectedBudget.value;
      final selectedCategory = controller.selectedCategory.value;

      return CategorySelectionLayout(
        hasLoading: controller.hasLoadingUnified.value,
        items: items,
        scrollController: controller.categoryScrollController,
        onCustomize: () => CategorySettingsPage.open(
          context,
          initialSection: CategoryType.expense,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final key = ValueKey('expense_${item.id}');

          final hasSelected = _hasItemSelected(
            item,
            selectedCategory,
            selectedBudget,
          );

          return UnifiedCategoryItemWidget(
            key: key,
            item: item,
            hasSelected: hasSelected,
            activeColor: activeColor,
            onTap: () {
              if (item.hasBudget) {
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

  /// A category that owns a budget is represented in the unified list by its
  /// budget item alone, so that card is the selected one whenever the category
  /// is selected — including the default selection, where the budget may not be
  /// resolved yet.
  bool _hasItemSelected(
    UnifiedCategoryItem item,
    CategoryEntity? selectedCategory,
    BudgetLimitEntity? selectedBudget,
  ) {
    final categoryMatches = selectedCategory?.id == item.categoryId;
    if (item.hasBudget) {
      return selectedBudget?.id == item.budgetId ||
          (selectedBudget == null && categoryMatches);
    }
    return selectedBudget == null && categoryMatches;
  }
}
