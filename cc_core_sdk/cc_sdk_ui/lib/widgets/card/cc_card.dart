import 'package:flutter/material.dart';

import '../../export_cc_sdk_ui.dart';

/// A reusable card widget with consistent styling across the app.
/// Supports semantic colors and shadows via theme system.
class CcCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final bool hasShadow;
  final VoidCallback? onTap;
  final CcInteractionType interactionType;
  final bool useDebounce;

  // Backward compatibility constructor (defaults to none if no onTap, else bounce)
  const CcCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.hasShadow = true,
    this.onTap,
    this.useDebounce = true,
  }) : interactionType = onTap == null
           ? CcInteractionType.none
           : CcInteractionType.bounce;

  // Private internal constructor
  const CcCard._({
    required this.child,
    required this.interactionType,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.hasShadow = true,
    this.onTap,
    this.useDebounce = true,
    super.key,
  });

  // Named constructors
  factory CcCard.bouncing({
    required Widget child,
    required VoidCallback onTap,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Color? backgroundColor,
    bool hasShadow = true,
    bool useDebounce = true,
    Key? key,
  }) => CcCard._(
    child: child,
    interactionType: CcInteractionType.bounce,
    onTap: onTap,
    padding: padding,
    width: width,
    height: height,
    backgroundColor: backgroundColor,
    hasShadow: hasShadow,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcCard.simple({
    required Widget child,
    required VoidCallback onTap,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Color? backgroundColor,
    bool hasShadow = true,
    bool useDebounce = true,
    Key? key,
  }) => CcCard._(
    child: child,
    interactionType: CcInteractionType.tap,
    onTap: onTap,
    padding: padding,
    width: width,
    height: height,
    backgroundColor: backgroundColor,
    hasShadow: hasShadow,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcCard.static({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Color? backgroundColor,
    bool hasShadow = true,
    Key? key,
  }) => CcCard._(
    child: child,
    interactionType: CcInteractionType.none,
    padding: padding,
    width: width,
    height: height,
    backgroundColor: backgroundColor,
    hasShadow: hasShadow,
    useDebounce: false,
    key: key,
  );

  @override
  Widget build(BuildContext context) {
    final cardBackgroundColor =
        backgroundColor ?? context.ccColorScheme.surface;

    final baseCard = Container(
      width: width,
      height: height,
      padding:
          padding ??
          EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: CcWidgetHelper.getBorderRoundedLG(),
        boxShadow: hasShadow
            ? CcWidgetHelper.getBoxShadows(
                context,
                bgColor: cardBackgroundColor,
              )
            : null,
      ),
      child: child,
    );

    // If type is none, return the base card directly
    if (interactionType == CcInteractionType.none) {
      return baseCard;
    }

    // Otherwise, wrap it in the interaction logic
    return CcInteractBtnWrapper(
      onTap: onTap ?? () {},
      useDebounce: useDebounce,
      isBouncing: interactionType == CcInteractionType.bounce,
      child: baseCard,
    );
  }
}
