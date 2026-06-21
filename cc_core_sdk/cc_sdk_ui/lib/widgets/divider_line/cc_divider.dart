import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';

class CcDividerLine extends StatelessWidget {
  const CcDividerLine({super.key, this.color, this.height, this.thickness});

  final Color? color;
  final double? height, thickness;

  @override
  Widget build(BuildContext context) => Divider(
    height: height ?? 16,
    thickness: thickness ?? 1,
    color: color ?? context.ccColorScheme.outlineVariant,
  );
}

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
    color: color ?? context.ccColorScheme.outlineVariant.withOpacity(0.5),
  );
}
