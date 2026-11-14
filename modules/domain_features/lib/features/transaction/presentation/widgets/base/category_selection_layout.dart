import 'dart:math' as math;

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/unified_category_item.dart';
import 'category_customize_tile.dart';

/// Base width of a category card, the gap between two cards, and the base
/// height of one card row.
///
/// [categoryItemWidth] is only the *preferred* width: the grid stretches or
/// shrinks cards so a whole number of columns fits the viewport (see
/// [CategoryGridMetrics]).
const double categoryItemWidth = 85;
const double categoryItemGap = 8;
const double categoryRowHeight = 80;

/// Cells the grid appends after the categories: the "Customize categories"
/// action. Kept as a constant so [revealCategoryGridItem] measures the same
/// grid the layout builds.
const int categoryGridTrailingCells = 1;

/// Geometry of the two-row category grid, shared by the layout and by
/// [revealCategoryGridItem] so an off-screen card can be located before the
/// grid has built it.
///
/// Items are laid out page by page, row-major inside a page: with 4 columns
/// the 8 most relevant items fill the first screen (0–3 on the top row, 4–7
/// on the bottom row), the next 8 fill the second page, and so on.
class CategoryGridMetrics {
  const CategoryGridMetrics._({
    required this.columns,
    required this.itemWidth,
    required this.gap,
    required this.leading,
  });

  factory CategoryGridMetrics.of(
    BuildContext context, {
    required double viewportWidth,
    required int itemCount,
  }) {
    final gap = context.respDim(categoryItemGap);
    final leading = context.respPadding(CcPaddingParams.PAGE_SM);
    final preferredExtent = context.respDim(categoryItemWidth) + gap;
    final columns = math.max(
      minColumns,
      ((viewportWidth - 2 * leading + gap) / preferredExtent).floor(),
    );

    // Everything fits on one page: fill the width exactly. Otherwise leave a
    // sliver of the next column peeking under the right-edge fade as a scroll
    // affordance.
    final fitsOnePage = itemCount <= columns * rows;
    final itemWidth = fitsOnePage
        ? (viewportWidth - 2 * leading - (columns - 1) * gap) / columns
        : (viewportWidth - leading - columns * gap) / (columns + _peek);

    return CategoryGridMetrics._(
      columns: columns,
      itemWidth: math.max(1, itemWidth),
      gap: gap,
      leading: leading,
    );
  }

  static const int rows = 2;
  static const int minColumns = 4;
  static const double _peek = 0.5;

  /// Columns visible per page.
  final int columns;
  final double itemWidth;
  final double gap;
  final double leading;

  int get pageSize => columns * rows;

  /// Number of grid slots needed for [itemCount] items. A trailing partial
  /// page only takes the columns it actually uses.
  int slotCount(int itemCount) {
    final fullPages = itemCount ~/ pageSize;
    final remainder = itemCount % pageSize;
    return fullPages * pageSize + math.min(remainder, columns) * rows;
  }

  /// Maps a grid slot (column-major, as a horizontal grid fills) to the item
  /// index shown there. May be `>= itemCount` for an empty trailing slot.
  int itemIndexForSlot(int slot) {
    final column = slot ~/ rows;
    final row = slot % rows;
    final page = column ~/ columns;
    return page * pageSize + row * columns + column % columns;
  }

  /// Grid column that holds the item at [index].
  int columnOfItem(int index) {
    final page = index ~/ pageSize;
    return page * columns + (index % pageSize) % columns;
  }

  /// Scroll offset of the leading edge of [column].
  double columnOffset(int column) => leading + column * (itemWidth + gap);
}

/// Scrolls the category grid so the card at [index] is visible, centering its
/// column. Does nothing when the card is already fully in view, so tapping a
/// visible card never shifts the grid under the finger.
///
/// [itemCount] is the number of categories; the trailing "Customize" cell the
/// layout appends ([categoryGridTrailingCells]) is accounted for here.
void revealCategoryGridItem({
  required ScrollController scrollController,
  required int index,
  required int itemCount,
  int attemptsLeft = 6,
}) {
  if (index < 0 || index >= itemCount) return;
  final cellCount = itemCount + categoryGridTrailingCells;

  void retry() {
    if (attemptsLeft <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => revealCategoryGridItem(
        scrollController: scrollController,
        index: index,
        itemCount: itemCount,
        attemptsLeft: attemptsLeft - 1,
      ),
    );
  }

  if (!scrollController.hasClients || scrollController.positions.isEmpty) {
    return retry();
  }
  final position = scrollController.positions.last;
  if (!position.hasContentDimensions || position.viewportDimension == 0.0) {
    return retry();
  }

  final context = position.context.notificationContext ?? Get.context;
  if (context == null) return;

  final viewport = position.viewportDimension;
  final metrics = CategoryGridMetrics.of(
    context,
    viewportWidth: viewport,
    itemCount: cellCount,
  );
  final start = metrics.columnOffset(metrics.columnOfItem(index));
  final end = start + metrics.itemWidth;

  const tolerance = 1.0;
  final alreadyVisible =
      start >= position.pixels - tolerance &&
      end <= position.pixels + viewport + tolerance;
  if (alreadyVisible) return;

  final target = (start - (viewport - metrics.itemWidth) / 2).clamp(
    position.minScrollExtent,
    position.maxScrollExtent,
  );
  scrollController.animateTo(
    target,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeOutCubic,
  );
}

/// Shared two-row category grid for the Transaction page.
///
/// Scrolls horizontally with faded edges; the first page shows the
/// `2 x columns` highest-priority items (see [CategoryGridMetrics]).
class CategorySelectionLayout extends StatelessWidget {
  const CategorySelectionLayout({
    super.key,
    required this.items,
    required this.scrollController,
    required this.itemBuilder,
    required this.onCustomize,
    this.isLoading = false,
  });

  final List<UnifiedCategoryItem> items;
  final ScrollController scrollController;
  final IndexedWidgetBuilder itemBuilder;

  /// Tapped on the trailing "Customize categories" cell.
  final VoidCallback onCustomize;

  /// Shows a shimmer grid of the same size instead of [items].
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderLabel(context),
        const CcSpaceXS(),
        isLoading ? _buildShimmerGrid(context) : _buildGrid(context),
      ],
    );
  }

  double _gridHeight(BuildContext context) =>
      CategoryGridMetrics.rows * context.respDim(categoryRowHeight) +
      (CategoryGridMetrics.rows - 1) * context.respDim(categoryItemGap);

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

  SliverGridDelegate _gridDelegate(CategoryGridMetrics metrics) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: CategoryGridMetrics.rows,
      mainAxisSpacing: metrics.gap,
      crossAxisSpacing: metrics.gap,
      mainAxisExtent: metrics.itemWidth,
    );
  }

  Widget _buildGrid(BuildContext context) {
    return HorizontalFadeScrollView(
      height: _gridHeight(context),
      scrollController: scrollController,
      builder: (gridScrollController) => LayoutBuilder(
        builder: (context, constraints) {
          final cellCount = items.length + categoryGridTrailingCells;
          final metrics = CategoryGridMetrics.of(
            context,
            viewportWidth: constraints.maxWidth,
            itemCount: cellCount,
          );
          return GridView.builder(
            scrollDirection: Axis.horizontal,
            controller: gridScrollController,
            padding: EdgeInsets.symmetric(horizontal: metrics.leading),
            gridDelegate: _gridDelegate(metrics),
            itemCount: metrics.slotCount(cellCount),
            itemBuilder: (context, slot) {
              final index = metrics.itemIndexForSlot(slot);
              if (index == items.length) {
                return CategoryCustomizeTile(onTap: onCustomize);
              }
              if (index > items.length) return const SizedBox.shrink();
              return itemBuilder(context, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerGrid(BuildContext context) {
    return SizedBox(
      height: _gridHeight(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final metrics = CategoryGridMetrics.of(
            context,
            viewportWidth: constraints.maxWidth,
            itemCount: 0,
          );
          return GridView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: metrics.leading),
            gridDelegate: _gridDelegate(metrics),
            itemCount: metrics.pageSize,
            itemBuilder: (context, _) => _buildShimmerCell(context),
          );
        },
      ),
    );
  }

  Widget _buildShimmerCell(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.ccColorScheme.onSurface.withValues(alpha: 0.04),
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
    );
  }
}
