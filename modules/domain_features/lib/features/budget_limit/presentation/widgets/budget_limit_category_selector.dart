import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class BudgetLimitCategorySelector extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final ValueChanged<CategoryEntity> onCategorySelected;
  final void Function(ScrollController)? onScrollControllerCreated;

  const BudgetLimitCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.onScrollControllerCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context),
        const CcSpaceSM(),
        _buildCategoryList(context),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return CcText(
      el.tr(CcLocaleKeys.budget_category),
      textStyle: context.ccTextTheme.labelMedium?.copyWith(
        color: context.ccColorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return HorizontalFadeScrollView(
      height: context.respDim(80),
      builder: (scrollController) {
        onScrollControllerCreated?.call(scrollController);
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          itemCount: categories.length,
          separatorBuilder: (_, _) => const CcSpaceSM(),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = selectedCategoryId == cat.id;
            return CcCategoryItem(
              iconCode: cat.iconCode,
              iconFamily: cat.iconFamily,
              nameKey: cat.nameKey,
              isSelected: isSelected,
              onTap: () => onCategorySelected(cat),
            );
          },
        );
      },
    );
  }
}
