import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../get_x/category_selection_controller.dart';

class CategorySelectionSection extends StatelessWidget {
  final Function(CategoryEntity)? onCategorySelected;
  final Color activeColor;

  /// Which categories to offer: [CategoryType.expense] or
  /// [CategoryType.income].
  final String type;

  /// When non-null, further restricts [type]'s categories to these
  /// `groupId`s — e.g. the Loan form passes only the Borrow or Lend
  /// `debt_loan` group depending on the selected direction. Null (the
  /// default) leaves every enabled category of [type] unfiltered.
  final List<String>? groupIds;

  /// Pre-select (and report) the first category once loaded.
  final bool autoSelectFirst;

  /// Overrides the section title (defaults to the localized "Category"
  /// label) — e.g. the Loan form's Đi vay direction relabels this "Hình
  /// thức vay" since it's picking a loan type, not a spending category.
  final String? title;

  /// Pre-select this category id once loaded (e.g. editing a transaction
  /// that already has a category). Takes priority over [autoSelectFirst].
  final String? initialSelectedCategoryId;

  const CategorySelectionSection({
    super.key,
    this.onCategorySelected,
    this.activeColor = PrjColors.primary,
    this.type = CategoryType.expense,
    this.groupIds,
    this.autoSelectFirst = false,
    this.title,
    this.initialSelectedCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    // Create controller with dependencies
    final controller = Get.put(
      CategorySelectionController(getIt<GetCategoriesUseCase>()),
      tag: 'category_selection_${type}_${groupIds?.join('_') ?? 'all'}',
    );

    // Set controller properties
    controller.type = type;
    controller.groupIds = groupIds;
    controller.autoSelectFirstEnabled = autoSelectFirst;
    controller.initialId = initialSelectedCategoryId;
    controller.onSelected = onCategorySelected;
    controller.refreshSelection();

    return Obx(() {
      if (controller.isLoading.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context),
            const CcSpaceXS(),
            _buildShimmerList(context),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          const CcSpaceXS(),
          _buildCategoryList(context, controller),
        ],
      );
    });
  }

  Widget _buildShimmerList(BuildContext context) {
    return SizedBox(
      height: context.respDim(75),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
        ),
        itemCount: 5,
        separatorBuilder: (context, index) => const CcSpaceSM(),
        itemBuilder: (context, index) => Container(
          width: context.respDim(68),
          padding: EdgeInsets.all(context.respDim(10)),
          decoration: BoxDecoration(
            color: context.ccColorScheme.onSurface.withAlpha(10),
            borderRadius: context.brLg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CcShimmer(
                width: context.respDim(35),
                height: context.respDim(35),
                borderRadius: context.brMd,
              ),
              const CcSpaceXS(),
              CcShimmer(
                width: context.respDim(40),
                height: context.respDim(10),
                borderRadius: context.brXs,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_SM,
      child: CcText(
        title ?? el.tr(CcLocaleKeys.transaction_category),
        textStyle: context.ccTextTheme.labelMedium?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    CategorySelectionController controller,
  ) {
    return HorizontalFadeScrollView(
      height: context.respDim(80),
      builder: (scrollController) => Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
          ),
          itemCount: controller.categories.length,
          separatorBuilder: (context, index) => const CcSpaceSM(),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected =
                controller.selectedCategoryId.value == category.id;
            return _buildCategoryItem(
              context,
              category,
              isSelected,
              controller,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    CategoryEntity category,
    bool isSelected,
    CategorySelectionController controller,
  ) {
    final scheme = context.ccColorScheme;

    return CcInkWell(
      onTap: () {
        controller.selectCategory(category);
        onCategorySelected?.call(category);
      },
      borderRadius: context.brLg,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isSelected)
            Positioned.fill(
              child: CcGlassyGradientBackground(
                centerColor: activeColor.withAlpha(30),
                endColor: activeColor.withAlpha(50),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: context.respDim(75),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withAlpha(10)
                  : scheme.onSurface.withAlpha(10),
              borderRadius: context.brLg,
              border: Border.all(
                color: isSelected
                    ? activeColor.withAlpha(20)
                    : scheme.onSurface.withAlpha(10),
                width: context.respDim(1),
              ),
            ),
            child: CcPadding(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryIcon(context, category, isSelected),
                  const CcSpaceXS(),
                  CcText(
                    el.tr(category.nameKey),
                    textAlign: TextAlign.center,
                    align: Alignment.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textStyle: context.ccTextTheme.labelSmall?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? activeColor : scheme.onSurfaceVariant,
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
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(
    BuildContext context,
    CategoryEntity category,
    bool isSelected,
  ) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(35),
      height: context.respDim(35),
      decoration: BoxDecoration(
        color: isSelected
            ? activeColor.withAlpha(20)
            : scheme.onSurface.withAlpha(10),
        borderRadius: context.brMd,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected)
            Positioned.fill(
              child: CcGlassyGradientIcon(
                centerColor: activeColor.withAlpha(30),
                endColor: activeColor.withAlpha(50),
              ),
            ),
          CcIcon(
            icon: iconDataFromCode(
              category.iconCode,
              fontFamily: category.iconFamily,
            ),
            size: context.respIconSize(baseSize: 18),
            color: isSelected ? activeColor : scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
