import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../models/unified_category_item.dart';

/// Shared layout for horizontal category lists on the Transaction page.
class CategorySelectionLayout extends StatelessWidget {
  const CategorySelectionLayout({
    super.key,
    required this.items,
    required this.scrollController,
    required this.itemBuilder,
  });

  final List<UnifiedCategoryItem> items;
  final ScrollController scrollController;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderLabel(context),
        const CcSpaceXS(),
        _buildHorizontalList(context),
      ],
    );
  }

  Widget _buildHeaderLabel(BuildContext context) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_SM,
      child: CcText(
        el.tr(CcLocaleKeys.transaction_category),
        textStyle: context.ccTextTheme.labelMedium?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context) {
    return HorizontalFadeScrollView(
      height: context.respDim(80),
      scrollController: scrollController,
      builder: (listScrollController) => ListView.separated(
        scrollDirection: Axis.horizontal,
        controller: listScrollController,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
        ),
        itemCount: items.length,
        separatorBuilder: (context, index) => const CcSpaceSM(),
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class UnifiedCategoryItemWidget extends StatelessWidget {
  const UnifiedCategoryItemWidget({
    super.key,
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
          if (isSelected) _buildActiveBackground(context),
          _buildItemContainer(context, scheme),
          if (item.isBudget) _buildBudgetIndicator(context, scheme),
        ],
      ),
    );
  }

  Widget _buildActiveBackground(BuildContext context) {
    return Positioned.fill(
      child: CcGlassyGradientBackground(
        centerColor: activeColor.withValues(alpha: 0.04),
        endColor: activeColor.withValues(alpha: 0.08),
      ),
    );
  }

  Widget _buildItemContainer(BuildContext context, ColorScheme scheme) {
    return AnimatedContainer(
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
            _buildLabel(context, scheme),
          ],
        ),
        CcPaddingParams.DESC_XS, // bottom
        CcPaddingParams.SECTION_XS, // left
        CcPaddingParams.SECTION_XS, // right
        CcPaddingParams.DESC_XS, // top
      ),
    );
  }

  Widget _buildLabel(BuildContext context, ColorScheme scheme) {
    return CcText(
      item.customName ?? el.tr(item.nameKey ?? ''),
      textAlign: TextAlign.center,
      align: Alignment.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textStyle: context.ccTextTheme.labelSmall?.copyWith(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? activeColor : scheme.onSurfaceVariant,
        fontSize: context.respFontSize(10),
      ),
    );
  }

  Widget _buildBudgetIndicator(BuildContext context, ColorScheme scheme) {
    return Positioned(
      top: context.respDim(6),
      right: context.respDim(6),
      child: Icon(
        Icons.bar_chart,
        size: context.respIconSize(baseSize: 14),
        color: isSelected
            ? activeColor.withAlpha(50)
            : scheme.onSurfaceVariant.withAlpha(50),
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
