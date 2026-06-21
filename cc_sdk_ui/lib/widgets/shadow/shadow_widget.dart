import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../../core/helper/cc_widget_helper.dart';

class ShadowWidget extends StatelessWidget {
  const ShadowWidget({
    Key? key,
    required this.child,
    this.bgColor,
    this.shadowColor,
  }) : super(key: key);

  final Widget child;
  final Color? bgColor;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: CcWidgetHelper.getBorderRoundedLG(),
      boxShadow: CcWidgetHelper.getBoxShadows(
        context,
        bgColor: bgColor ?? context.ccColorScheme.surface,
        shadowColor: shadowColor ?? context.ccColorScheme.shadow,
      ),
    ),
    child: child,
  );
}
