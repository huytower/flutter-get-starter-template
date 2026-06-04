import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_padding_params.dart';
import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import '../../core/helper/cc_widget_helper.dart';

/// A reusable card widget with consistent styling across the app.
/// Supports semantic colors and shadows via theme system.
class CcCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final bool hasShadow;

  const CcCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardBackgroundColor =
        backgroundColor ?? context.ccColorScheme.surface;
    return Container(
      width: width,
      height: height,
      padding:
          padding ??
          EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: CcWidgetHelper.getBorderRoundedLG(),
        boxShadow: hasShadow
            ? CcWidgetHelper.getBoxShadows(
                context,
                bgColor: cardBackgroundColor,
              )
            : null,
      ),
      child: child,
    );
  }
}
