import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';

class CcDividerVerticalLine extends StatelessWidget {
  const CcDividerVerticalLine({super.key, this.color, this.width, this.height});

  final Color? color;
  final double? width, height;

  @override
  Widget build(BuildContext context) => Container(
    width: width ?? context.respDim(1.0),
    height: height ?? context.respDim(12.0),
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
      width: width ?? context.respDim(96.0),
      height: context.respDim(6.0),
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
      width: width ?? context.respDim(128.0),
      height: context.respDim(6.0),
    ),
  );
}
