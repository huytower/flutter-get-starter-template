import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import 'cc_text.dart';

/// POPULAR WIDGET
/// Main Title widget
class TitleWidget extends StatelessWidget {
  const TitleWidget({
    Key? key,
    required this.title,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.align,
  }) : super(key: key);

  final String title;

  final Color? color;

  final double? fontSize;

  final FontWeight? fontWeight;

  final Alignment? align;

  @override
  Widget build(BuildContext context) => CcText(
    title,
    align: align ?? Alignment.centerLeft,
    fontWeight: fontWeight ?? FontWeight.w500,
    fontSize: fontSize ?? context.respFontSize(16.0),
    color: color ?? context.ccColorScheme.onSurface,
  );
}
