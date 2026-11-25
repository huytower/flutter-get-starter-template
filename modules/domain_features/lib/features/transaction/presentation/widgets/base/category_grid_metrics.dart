import 'dart:math' as math;

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/widgets.dart';

import 'category_selection_layout.dart';

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
    required this.start,
    required this.end,
  });

  /// [inset] is the content inset of a wide window ([CcContentInset]); 0 on
  /// phones and portrait tablets, where the metrics are unchanged.
  factory CategoryGridMetrics.of(
    BuildContext context, {
    required double viewportWidth,
    required int itemCount,
    double inset = 0,
  }) {
    final gap = context.respDim(categoryItemGap);
    final leading = context.respPadding(CcPaddingParams.PAGE_SM);
    final preferredExtent = context.respDim(categoryItemWidth) + gap;
    int columnsFor(double width) => math.max(
      minColumns,
      ((width - 2 * leading + gap) / preferredExtent).floor(),
    );

    // Everything fits on one page of the content width: fill that width
    // exactly, centred like the rest of the content.
    final contentWidth = viewportWidth - 2 * inset;
    final contentColumns = columnsFor(contentWidth);
    if (itemCount <= contentColumns * rows) {
      return CategoryGridMetrics._(
        columns: contentColumns,
        itemWidth: math.max(
          1,
          (contentWidth - 2 * leading - (contentColumns - 1) * gap) /
              contentColumns,
        ),
        gap: gap,
        start: leading + inset,
        end: leading + inset,
      );
    }

    // It scrolls: start aligned with the content and run to the trailing edge
    // of the screen, leaving a sliver of the next column peeking under the
    // edge fade as a scroll affordance.
    final scrollWidth = viewportWidth - inset;
    final columns = columnsFor(scrollWidth);
    return CategoryGridMetrics._(
      columns: columns,
      itemWidth: math.max(
        1,
        (scrollWidth - leading - columns * gap) / (columns + _peek),
      ),
      gap: gap,
      start: leading + inset,
      end: leading,
    );
  }

  static const int rows = 2;
  static const int minColumns = 4;
  static const double _peek = 0.5;

  /// Columns visible per page.
  final int columns;
  final double itemWidth;
  final double gap;

  /// Padding before the first and after the last column.
  final double start;
  final double end;

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
  double columnOffset(int column) => start + column * (itemWidth + gap);
}

