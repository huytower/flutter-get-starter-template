import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/util/wallet_icon_helper.dart';

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
      height: context.respDim(90),
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
            return _buildCategoryItem(context, cat, isSelected);
          },
        );
      },
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    CategoryEntity cat,
    bool isSelected,
  ) {
    final scheme = context.ccColorScheme;

    return GestureDetector(
      onTap: () => onCategorySelected(cat),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isSelected)
            const Positioned.fill(child: CcGlassyGradientBackground()),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: context.respDim(68),
            padding: EdgeInsets.all(context.respDim(10)),
            decoration: BoxDecoration(
              color: isSelected
                  ? scheme.primaryContainer.withValues(alpha: 0.1)
                  : scheme.onSurface.withOpacity(0.04),
              borderRadius: context.brLg,
              border: Border.all(
                color: isSelected
                    ? scheme.primary.withOpacity(0.2)
                    : scheme.onSurface.withOpacity(0.08),
                width: context.respDim(1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCategoryIcon(context, cat, isSelected),
                const CcSpaceXS(),
                Text(
                  el.tr(cat.nameKey),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.ccTextTheme.labelSmall?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(
    BuildContext context,
    CategoryEntity cat,
    bool isSelected,
  ) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(32),
      height: context.respDim(32),
      decoration: BoxDecoration(
        color: isSelected
            ? scheme.primary.withOpacity(0.12)
            : scheme.onSurface.withOpacity(0.08),
        borderRadius: context.brMd,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected) const Positioned.fill(child: CcGlassyGradientIcon()),
          CcIcon(
            icon: iconDataFromCode(cat.iconCode, fontFamily: cat.iconFamily),
            size: context.respIconSize(baseSize: 18),
            color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
