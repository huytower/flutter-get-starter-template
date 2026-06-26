import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/config/tokens/cc_base_colors.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import '../../core/helper/cc_widget_helper.dart';

/// POPULAR WIDGET
/// Skeleton|Shimmer|Waiting|Loading text (Loading text ui), is showing while loading data from API response.
class TitleLoadingWidget extends StatelessWidget {
  const TitleLoadingWidget({Key? key, this.lineWidth, this.lineHeight})
    : super(key: key);

  final double? lineHeight, lineWidth;

  @override
  Widget build(BuildContext context) => getEmptyContainer(context);

  Widget getEmptyContainer(BuildContext context) => SizedBox(
    width: lineWidth ?? context.respIconSize(baseSize: 50.0),
    height: lineHeight ?? context.respIconSize(baseSize: 14.0),
    child: Shimmer.fromColors(
      baseColor: CcBaseColors.neutral5,
      highlightColor: Colors.yellow,
      child: Container(
        width: lineWidth ?? context.respIconSize(baseSize: 50.0),
        height: context.respIconSize(baseSize: 12.0),
        decoration: BoxDecoration(
          color: CcBaseColors.neutral5,
          borderRadius: CcWidgetHelper.getBorderRoundedLG(),
        ),
      ),
    ),
  );
}
