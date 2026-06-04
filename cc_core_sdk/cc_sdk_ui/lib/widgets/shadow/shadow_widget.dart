import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_base_colors.dart';
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
        bgColor: bgColor ?? CcBaseColors.white80,
        shadowColor: shadowColor ?? CcBaseColors.brand300,
      ),
    ),
    child: child,
  );
}
