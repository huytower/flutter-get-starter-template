import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// A horizontal list of shimmering category items used as a loading placeholder.
///
/// It provides high configurability for different feature layouts (e.g. Asset Selectors)
/// while maintaining a consistent visual language.
class PrjCategoryShimmerList extends StatelessWidget {
  const PrjCategoryShimmerList({
    super.key,
    this.itemCount = 5,
    this.height,
    this.itemWidth,
    this.verticalPadding,
    this.horizontalPadding,
    this.itemPadding,
    this.separator,
    this.shimmerLabelWidth,
  });

  final int itemCount;

  /// Height of the entire scrollable area.
  final double? height;

  /// Width of each shimmering item box.
  final double? itemWidth;

  /// Vertical padding for the list's content.
  final double? verticalPadding;

  /// Horizontal padding for the list's content.
  final double? horizontalPadding;

  /// Internal padding for each shimmering item box.
  final EdgeInsetsGeometry? itemPadding;

  /// Separator widget between items.
  final Widget? separator;

  /// Width of the shimmering label line.
  final double? shimmerLabelWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? context.respDim(80),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal:
              horizontalPadding ?? context.respPadding(CcPaddingParams.PAGE_SM),
          vertical: verticalPadding ?? 0,
        ),
        itemCount: itemCount,
        separatorBuilder: (context, index) => separator ?? const CcSpaceSM(),
        itemBuilder: (context, index) => Container(
          width: itemWidth ?? context.respDim(85),
          padding: itemPadding ?? EdgeInsets.all(context.respDim(10)),
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
                width: shimmerLabelWidth ?? context.respDim(40),
                height: context.respDim(10),
                borderRadius: context.brXs,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
