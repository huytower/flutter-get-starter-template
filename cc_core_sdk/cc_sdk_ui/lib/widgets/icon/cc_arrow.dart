import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import '../button/cc_bounce_animation.dart';
import '../button/cc_interaction_type.dart';

class CcArrowRight extends StatelessWidget {
  final Color? iconColor;
  final double? height, width;
  final VoidCallback? onTap;
  final CcInteractionType interactionType;

  // Backward compatibility constructor (defaults to bounce)
  const CcArrowRight({
    super.key,
    this.onTap,
    this.iconColor,
    this.height,
    this.width,
  }) : interactionType = CcInteractionType.bounce;

  // Private internal constructor
  const CcArrowRight._({
    required this.interactionType,
    this.onTap,
    this.iconColor,
    this.height,
    this.width,
    super.key,
  });

  // Named constructors
  factory CcArrowRight.bouncing({
    VoidCallback? onTap,
    Color? iconColor,
    double? height,
    double? width,
    Key? key,
  }) =>
      CcArrowRight._(
        interactionType: CcInteractionType.bounce,
        onTap: onTap,
        iconColor: iconColor,
        height: height,
        width: width,
        key: key,
      );

  factory CcArrowRight.simple({
    VoidCallback? onTap,
    Color? iconColor,
    double? height,
    double? width,
    Key? key,
  }) =>
      CcArrowRight._(
        interactionType: CcInteractionType.tap,
        onTap: onTap,
        iconColor: iconColor,
        height: height,
        width: width,
        key: key,
      );

  factory CcArrowRight.static({
    Color? iconColor,
    double? height,
    double? width,
    Key? key,
  }) =>
      CcArrowRight._(
        interactionType: CcInteractionType.none,
        iconColor: iconColor,
        height: height,
        width: width,
        key: key,
      );

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: SizedBox(
        width: width ?? context.respDim(25.0),
        height: height,
        child: Icon(
          Icons.skip_next,
          color: iconColor ?? context.ccColorScheme.onSurface,
          size: context.respIconSize(baseSize: 15.0),
        ),
      ),
    );

    switch (interactionType) {
      case CcInteractionType.none:
        return child;
      case CcInteractionType.tap:
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: child,
        );
      case CcInteractionType.bounce:
        return CcBounceAnimation(onTap: onTap ?? () {}, child: child);
    }
  }
}
