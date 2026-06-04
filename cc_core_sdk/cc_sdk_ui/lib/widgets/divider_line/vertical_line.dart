import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';

class CcDividerVerticalLine extends StatelessWidget {
  const CcDividerVerticalLine({super.key, this.color, this.width, this.height});

  final Color? color;
  final double? width, height;

  @override
  Widget build(BuildContext context) => Container(
    width: width ?? 1,
    height: height ?? 12,
    color: color ?? context.ccColorScheme.outlineVariant,
  );
}

class CcDividerIndicatorLine extends StatelessWidget {
  const CcDividerIndicatorLine({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      color: context.ccColorScheme.outlineVariant,
      width: width ?? 96,
      height: 6,
    ),
  );
}

class CcDividerShadowLine extends StatelessWidget {
  const CcDividerShadowLine({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      color: context.ccColorScheme.shadow.withOpacity(0.1),
      width: width ?? 128,
      height: 6,
    ),
  );
}
