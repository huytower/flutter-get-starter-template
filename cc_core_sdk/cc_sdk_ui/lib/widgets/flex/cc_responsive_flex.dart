import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';

/// A responsive flex widget that adapts its layout based on screen size.
///
/// On mobile: Uses vertical layout (column)
/// On tablet: Uses horizontal layout (row) with 2 columns
/// On desktop: Uses horizontal layout (row) with 3 columns
///
/// Example usage:
/// ```dart
/// CcResponsiveFlex(
///   children: [
///     MyWidget1(),
///     MyWidget2(),
///     MyWidget3(),
///   ],
/// )
/// ```
class CcResponsiveFlex extends StatelessWidget {
  /// The children widgets to display.
  final List<Widget> children;

  /// Spacing between children.
  final double spacing;

  /// Run spacing (for wrap layout).
  final double runSpacing;

  /// Alignment for the main axis.
  final MainAxisAlignment mainAxisAlignment;

  /// Alignment for the cross axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// Whether to use Wrap instead of Row/Column.
  final bool useWrap;

  /// Custom number of columns for tablet.
  final int? tabletColumns;

  /// Custom number of columns for desktop.
  final int? desktopColumns;

  const CcResponsiveFlex({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.useWrap = false,
    this.tabletColumns,
    this.desktopColumns,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;

    // Mobile: Vertical layout
    if (screenType == ScreenType.mobile ||
        screenType == ScreenType.smallMobile) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        children: _buildSpacedChildren(spacing, isVertical: true),
      );
    }

    // Tablet: 2 columns
    if (screenType == ScreenType.tablet) {
      final columns = tabletColumns ?? 2;
      return _buildResponsiveLayout(context, columns);
    }

    // Desktop: 3 columns
    final columns = desktopColumns ?? 3;
    return _buildResponsiveLayout(context, columns);
  }

  Widget _buildResponsiveLayout(BuildContext context, int columns) {
    if (useWrap) {
      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: children,
      );
    }

    // Build rows with specified number of columns
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += columns) {
      final rowChildren = <Widget>[];
      for (int j = 0; j < columns; j++) {
        final index = i + j;
        if (index < children.length) {
          rowChildren.add(Expanded(child: children[index]));
        } else {
          rowChildren.add(const Expanded(child: SizedBox()));
        }
      }
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: Row(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            children: _buildSpacedChildren(spacing, widgets: rowChildren),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  List<Widget> _buildSpacedChildren(
    double spacing, {
    bool isVertical = false,
    List<Widget>? widgets,
  }) {
    final items = widgets ?? children;
    if (items.isEmpty) return items;

    final spacedChildren = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      spacedChildren.add(items[i]);
      if (i < items.length - 1) {
        if (isVertical) {
          spacedChildren.add(SizedBox(height: spacing));
        } else {
          spacedChildren.add(SizedBox(width: spacing));
        }
      }
    }
    return spacedChildren;
  }
}
