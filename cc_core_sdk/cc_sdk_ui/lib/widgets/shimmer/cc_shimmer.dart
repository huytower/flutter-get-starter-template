import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../core/config/tokens/cc_circular_params.dart';
import '../../core/extensions/cc_context_extension.dart';

class CcShimmer extends StatelessWidget {
  const CcShimmer({
    Key? key,
    this.width,
    this.height = 20,
    this.borderRadius,
    this.margin,
    this.baseColor,
    this.highlightColor,
    this.duration,
    this.enabled = true,
  }) : super(key: key);

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? duration;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: duration ?? const Duration(milliseconds: 1500),
      color: baseColor ?? context.ccColorScheme.surfaceVariant,
      colorOpacity: 0.5,
      enabled: enabled,
      direction: const ShimmerDirection.fromLTRB(),
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius:
              borderRadius ??
              BorderRadius.circular(CcCircularParams.SQUARE_TOP),
          color: context.ccColorScheme.surfaceVariant,
        ),
      ),
    );
  }
}
