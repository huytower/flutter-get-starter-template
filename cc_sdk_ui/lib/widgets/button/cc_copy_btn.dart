import 'package:flutter/material.dart';

import '../../export_cc_sdk_ui.dart';

/// Copy icon button with copy icon
class CcCopyBtn extends StatelessWidget {
  final Color? iconColor;
  final double? height, width;
  final VoidCallback? onTap;
  final CcInteractionType interactionType;
  final bool useDebounce;

  // Backward compatibility constructor (defaults to bounce)
  const CcCopyBtn({
    super.key,
    required this.onTap,
    this.iconColor,
    this.height,
    this.width,
    this.useDebounce = true,
  }) : interactionType = CcInteractionType.bounce;

  // Private internal constructor
  const CcCopyBtn._({
    required this.interactionType,
    this.onTap,
    this.iconColor,
    this.height,
    this.width,
    this.useDebounce = true,
    super.key,
  });

  // Named constructors
  factory CcCopyBtn.bouncing({
    required VoidCallback onTap,
    Color? iconColor,
    double? height,
    double? width,
    bool useDebounce = true,
    Key? key,
  }) => CcCopyBtn._(
    interactionType: CcInteractionType.bounce,
    onTap: onTap,
    iconColor: iconColor,
    height: height,
    width: width,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcCopyBtn.simple({
    required VoidCallback onTap,
    Color? iconColor,
    double? height,
    double? width,
    bool useDebounce = true,
    Key? key,
  }) => CcCopyBtn._(
    interactionType: CcInteractionType.tap,
    onTap: onTap,
    iconColor: iconColor,
    height: height,
    width: width,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcCopyBtn.static({
    Color? iconColor,
    double? height,
    double? width,
    Key? key,
  }) => CcCopyBtn._(
    interactionType: CcInteractionType.none,
    iconColor: iconColor,
    height: height,
    width: width,
    useDebounce: false,
    key: key,
  );

  @override
  Widget build(BuildContext context) {
    final baseIcon = Padding(
      padding: EdgeInsets.all(context.respPadding(4)),
      child: CcIcon(
        icon: Icons.copy,
        size: context.respIconSize(baseSize: 20.0),
        align: Alignment.center,
        color: iconColor ?? context.ccColorScheme.onSurface,
      ),
    );

    // If type is none, return the base icon directly
    if (interactionType == CcInteractionType.none) {
      return baseIcon;
    }

    // Otherwise, wrap it in the interaction logic
    return CcInteractBtnWrapper(
      onTap: onTap ?? () {},
      useDebounce: useDebounce,
      isBouncing: interactionType == CcInteractionType.bounce,
      child: baseIcon,
    );
  }
}
