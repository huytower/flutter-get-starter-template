import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../../core/helper/cc_widget_helper.dart';

class CcInkWell extends StatelessWidget {
  const CcInkWell({
    super.key,
    required this.onTap,
    this.child,
    this.borderRadius,
    this.splashColor,
  });

  final VoidCallback onTap;
  final Widget? child;
  final BorderRadius? borderRadius;
  final Color? splashColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius ?? CcWidgetHelper.getCircleBorderRadius(),
      splashColor:
          splashColor ?? context.ccColorScheme.primary.withOpacity(0.1),
      child: child,
    );
  }
}
