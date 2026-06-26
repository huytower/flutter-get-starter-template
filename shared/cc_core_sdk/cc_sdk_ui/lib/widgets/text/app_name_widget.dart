import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_base_colors.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import 'cc_text.dart';

class AppNameWidget extends StatelessWidget {
  const AppNameWidget(
    this.name, {
    Key? key,
    this.fontSize = 24,
    this.color,
    this.align,
  }) : super(key: key);

  final String name;

  final double fontSize;

  final Color? color;

  final Alignment? align;

  @override
  Widget build(BuildContext context) => CcText(
    name,
    align: align ?? Alignment.center,
    fontWeight: FontWeight.w700,
    fontSize: context.respFontSize(fontSize),
    color: color ?? CcBaseColors.neutral40,
  );
}
