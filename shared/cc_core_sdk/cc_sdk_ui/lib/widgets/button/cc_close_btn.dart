import 'package:flutter/material.dart';

import '../../export_cc_sdk_ui.dart';

/// Standardized Close Button.
///
/// If no [icon] is provided, it defaults to [Icons.close].
class CcCloseBtn extends StatelessWidget {
  final Color? bgColor;
  final double? height, width;
  final Widget? icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final CcInteractionType interactionType;
  final bool useDebounce;

  // Backward compatibility constructor (defaults to bounce)
  const CcCloseBtn({
    required this.onTap,
    this.bgColor,
    this.height,
    this.width,
    this.icon,
    this.iconColor,
    this.useDebounce = true,
    super.key,
  }) : interactionType = CcInteractionType.bounce;

  // Private internal constructor
  const CcCloseBtn._({
    required this.interactionType,
    this.onTap,
    this.bgColor,
    this.height,
    this.width,
    this.icon,
    this.iconColor,
    this.useDebounce = true,
    super.key,
  });

  // Named constructors (The "API" for other developers)
  factory CcCloseBtn.bouncing({
    required VoidCallback onTap,
    Color? bgColor,
    double? height,
    double? width,
    Widget? icon,
    Color? iconColor,
    bool useDebounce = true,
    Key? key,
  }) => CcCloseBtn._(
    interactionType: CcInteractionType.bounce,
    onTap: onTap,
    bgColor: bgColor,
    height: height,
    width: width,
    icon: icon,
    iconColor: iconColor,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcCloseBtn.simple({
    required VoidCallback onTap,
    Color? bgColor,
    double? height,
    double? width,
    Widget? icon,
    Color? iconColor,
    bool useDebounce = true,
    Key? key,
  }) => CcCloseBtn._(
    interactionType: CcInteractionType.tap,
    onTap: onTap,
    bgColor: bgColor,
    height: height,
    width: width,
    icon: icon,
    iconColor: iconColor,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcCloseBtn.static({
    Color? bgColor,
    double? height,
    double? width,
    Widget? icon,
    Color? iconColor,
    Key? key,
  }) => CcCloseBtn._(
    interactionType: CcInteractionType.none,
    bgColor: bgColor,
    height: height,
    width: width,
    icon: icon,
    iconColor: iconColor,
    useDebounce: false,
    key: key,
  );

  @override
  Widget build(BuildContext context) {
    final double defaultSize = context.respIconSize(baseSize: 35.0);
    final double defaultIconSize = context.respIconSize(baseSize: 20.0);

    final baseBtn = SizedBox(
      width: width ?? defaultSize,
      height: height ?? defaultSize,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.transparent,
          shape: BoxShape.circle,
        ),
        child:
            icon ??
            Icon(
              Icons.close,
              size: defaultIconSize,
              color: iconColor ?? context.ccColorScheme.onSurface,
            ),
      ),
    );

    // If type is none, return the base button directly
    if (interactionType == CcInteractionType.none) {
      return Center(child: baseBtn);
    }

    // Otherwise, wrap it in the interaction logic
    return Center(
      child: CcInteractBtnWrapper(
        onTap: onTap ?? () {},
        useDebounce: useDebounce,
        isBouncing: interactionType == CcInteractionType.bounce,
        child: baseBtn,
      ),
    );
  }
}
