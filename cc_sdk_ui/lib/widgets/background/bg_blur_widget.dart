import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_base_colors.dart';

class BackgroundBlurWidget extends StatelessWidget {
  const BackgroundBlurWidget({
    Key? key,
    required this.child,
    this.sigmaX = 5.0,
    this.sigmaY = 5.0,
    this.color,
  }) : super(key: key);

  final Widget child;
  final double sigmaX, sigmaY;
  final Color? color;

  @override
  Widget build(BuildContext context) => ClipRRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
      child: Container(color: color ?? CcBaseColors.white20, child: child),
    ),
  );
}
