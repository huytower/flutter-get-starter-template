import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../models/unified_category_item.dart';

/// Base width of a category card in the horizontal row, and the gap between
/// two cards (the row separates items with [CcSpaceSM], also 8pt).
///
/// Shared with the form controllers so an off-screen card can be located by
/// its estimated offset before the list has built it.
const double categoryItemWidth = 85;
const double categoryItemGap = 8;

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
