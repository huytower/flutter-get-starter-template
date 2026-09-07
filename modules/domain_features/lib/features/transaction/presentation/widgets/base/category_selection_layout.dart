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
        ),
      ],
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
