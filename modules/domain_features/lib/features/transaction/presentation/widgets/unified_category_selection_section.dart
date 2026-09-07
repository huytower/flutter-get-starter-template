import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/expense_form_controller.dart';
import '../models/unified_category_item.dart';

class UnifiedCategorySelectionSection extends StatelessWidget {
  const UnifiedCategorySelectionSection({
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcSymmetricPadding(
            horizontal: CcPaddingParams.PAGE_SM,
            child: CcText(
              el.tr(CcLocaleKeys.transaction_category),
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const CcSpaceXS(),
          HorizontalFadeScrollView(
            height: context.respDim(80),
            builder: (scrollController) => ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
              ),
              itemCount: items.length,
              separatorBuilder: (context, index) => const CcSpaceSM(),
              itemBuilder: (context, index) {
                final item = items[index];

                bool isSelected = false;
                if (item.isBudget) {
                  isSelected = selectedBudget?.id == item.budgetId;
                } else {
                  // Only highlight the general category if no specific budget is selected
                  // or if this category doesn't have any budgets.
                  isSelected =
                      selectedBudget == null &&
                      selectedCategory?.id == item.categoryId;
                }

                return _UnifiedItem(
                  item: item,
                  isSelected: isSelected,
                  activeColor: activeColor,
                  onTap: () {
                    if (item.isBudget) {
                      // Since we already have the ID, we can find it in the budget controller
                      final realBudget = controller.budgets
                          .firstWhereOrNull((b) => b.budget.id == item.budgetId)
                          ?.budget;
                      if (realBudget != null) {
                        controller.setBudget(realBudget);
                      }
                    } else {
                      final cat = controller.getCachedCategoryById(
                        item.categoryId,
                      );
                      if (cat != null) {
                        controller.setCategory(cat);
                      }
                    }
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _UnifiedItem extends StatelessWidget {
  const _UnifiedItem({
    required this.item,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final UnifiedCategoryItem item;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return CcInteractBtnWrapper(
      onTap: onTap,
      isBouncing: true,
      useDebounce: false,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isSelected)
            Positioned.fill(
              child: CcGlassyGradientBackground(
                centerColor: activeColor.withValues(alpha: 0.04),
                endColor: activeColor.withValues(alpha: 0.08),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: context.respDim(85),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.02)
                  : scheme.onSurface.withValues(alpha: 0.02),
              borderRadius: context.brLg,
              border: Border.all(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.04)
                    : scheme.onSurface.withValues(alpha: 0.02),
                width: context.respDim(1),
              ),
            ),
            child: CcPadding(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(context),
                  const CcSpaceXS(),
                  CcText(
                    item.displayName,
                    textAlign: TextAlign.center,
                    align: Alignment.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textStyle: context.ccTextTheme.labelSmall?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? activeColor : scheme.onSurfaceVariant,
                      fontSize: context.respFontSize(10),
                    ),
                  ),
                ],
              ),
              4,
              6,
              6,
              4,
            ),
          ),
          if (item.isBudget)
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                Icons.bolt_rounded,
                size: 10,
                color: isSelected
                    ? activeColor
                    : scheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(35),
      height: context.respDim(35),
      decoration: BoxDecoration(
        color: isSelected
            ? activeColor.withValues(alpha: 0.04)
            : scheme.onSurface.withValues(alpha: 0.02),
        borderRadius: context.brMd,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected)
            Positioned.fill(
              child: CcGlassyGradientIcon(
                centerColor: activeColor.withValues(alpha: 0.08),
                endColor: activeColor.withValues(alpha: 0.16),
              ),
            ),
          CcIcon(
            icon: iconDataFromCode(item.iconCode, fontFamily: item.iconFamily),
            size: context.respIconSize(baseSize: 18),
            color: isSelected ? activeColor : scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
