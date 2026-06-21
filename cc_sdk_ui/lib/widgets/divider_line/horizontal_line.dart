import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_base_colors.dart';

class CcDividerHorizontalLine extends StatelessWidget {
  const CcDividerHorizontalLine({
    super.key,
    this.color,
    this.height,
    this.width,
  });

  final Color? color;
  final double? height, width;

  @override
  Widget build(BuildContext context) => Container(
    height: height ?? 1,
    width: width ?? double.infinity,
    color: color ?? CcBaseColors.neutral5,
  );
}
