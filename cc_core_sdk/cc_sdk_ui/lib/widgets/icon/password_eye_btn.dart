import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import '../button/cc_bounce_animation.dart';
import '../button/cc_interaction_type.dart';

/// Password eye button with Material icon
class PasswordEyeButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final CcInteractionType interactionType;

  // Backward compatibility constructor (defaults to bounce)
  const PasswordEyeButtonWidget({
    super.key,
    this.icon = Icons.visibility,
    this.onTap,
    this.iconColor,
  }) : interactionType = CcInteractionType.bounce;

  // Private internal constructor
  const PasswordEyeButtonWidget._({
    required this.interactionType,
    this.icon = Icons.visibility,
    this.onTap,
    this.iconColor,
    super.key,
  });

  // Named constructors
  factory PasswordEyeButtonWidget.bouncing({
    IconData icon = Icons.visibility,
    VoidCallback? onTap,
    Color? iconColor,
    Key? key,
  }) =>
      PasswordEyeButtonWidget._(
        interactionType: CcInteractionType.bounce,
        icon: icon,
        onTap: onTap,
        iconColor: iconColor,
        key: key,
      );

  factory PasswordEyeButtonWidget.simple({
    IconData icon = Icons.visibility,
    VoidCallback? onTap,
    Color? iconColor,
    Key? key,
  }) =>
      PasswordEyeButtonWidget._(
        interactionType: CcInteractionType.tap,
        icon: icon,
        onTap: onTap,
        iconColor: iconColor,
        key: key,
      );

  factory PasswordEyeButtonWidget.static({
    IconData icon = Icons.visibility,
    Color? iconColor,
    Key? key,
  }) =>
      PasswordEyeButtonWidget._(
        interactionType: CcInteractionType.none,
        icon: icon,
        iconColor: iconColor,
        key: key,
      );

  @override
  Widget build(BuildContext context) {
    final child = Icon(
      icon,
      size: context.respDim(24),
      color: iconColor ?? context.ccColorScheme.onSurface,
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
