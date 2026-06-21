import 'package:flutter/material.dart';

import '../../export_cc_sdk_ui.dart';

class CcBaseBtn extends StatelessWidget {
  final String? title;
  final List<Color>? bgColor;
  final Color? textColor;
  final bool isEnable;
  final double? height, width;
  final BorderRadius? borderRadius;
  final List<Color>? colorsGradient;
  final bool allowShowLoading;
  final VoidCallback? onTap;
  final CcInteractionType interactionType;
  final bool useDebounce;

  // Backward compatibility constructor (defaults to bounce)
  const CcBaseBtn({
    super.key,
    this.title,
    this.bgColor,
    this.textColor,
    this.isEnable = true,
    this.height,
    this.width,
    this.borderRadius,
    this.colorsGradient,
    this.allowShowLoading = true,
    this.onTap,
    this.useDebounce = true,
  }) : interactionType = CcInteractionType.bounce;

  // Private internal constructor
  const CcBaseBtn._({
    required this.interactionType,
    this.title,
    this.bgColor,
    this.textColor,
    this.isEnable = true,
    this.height,
    this.width,
    this.borderRadius,
    this.colorsGradient,
    this.allowShowLoading = true,
    this.onTap,
    this.useDebounce = true,
    super.key,
  });

  // Named constructors
  factory CcBaseBtn.bouncing({
    Key? key,
    String? title,
    List<Color>? bgColor,
    Color? textColor,
    bool isEnable = true,
    double? height,
    double? width,
    BorderRadius? borderRadius,
    List<Color>? colorsGradient,
    bool allowShowLoading = true,
    VoidCallback? onTap,
    bool useDebounce = true,
  }) => CcBaseBtn._(
    interactionType: CcInteractionType.bounce,
    title: title,
    bgColor: bgColor,
    textColor: textColor,
    isEnable: isEnable,
    height: height,
    width: width,
    borderRadius: borderRadius,
    colorsGradient: colorsGradient,
    allowShowLoading: allowShowLoading,
    onTap: onTap,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcBaseBtn.simple({
    Key? key,
    String? title,
    List<Color>? bgColor,
    Color? textColor,
    bool isEnable = true,
    double? height,
    double? width,
    BorderRadius? borderRadius,
    List<Color>? colorsGradient,
    bool allowShowLoading = true,
    VoidCallback? onTap,
    bool useDebounce = true,
  }) => CcBaseBtn._(
    interactionType: CcInteractionType.tap,
    title: title,
    bgColor: bgColor,
    textColor: textColor,
    isEnable: isEnable,
    height: height,
    width: width,
    borderRadius: borderRadius,
    colorsGradient: colorsGradient,
    allowShowLoading: allowShowLoading,
    onTap: onTap,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcBaseBtn.static({
    Key? key,
    String? title,
    List<Color>? bgColor,
    Color? textColor,
    bool isEnable = true,
    double? height,
    double? width,
    BorderRadius? borderRadius,
    List<Color>? colorsGradient,
    bool allowShowLoading = true,
  }) => CcBaseBtn._(
    interactionType: CcInteractionType.none,
    title: title,
    bgColor: bgColor,
    textColor: textColor,
    isEnable: isEnable,
    height: height,
    width: width,
    borderRadius: borderRadius,
    colorsGradient: colorsGradient,
    allowShowLoading: allowShowLoading,
    useDebounce: false,
    key: key,
  );

  @override
  Widget build(BuildContext context) {
    final baseContent = Container(
      height: height ?? context.respDim(48.0),
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? CcWidgetHelper.getBorderRoundedSM(),
        gradient: LinearGradient(
          colors:
              bgColor ??
              colorsGradient ??
              [
                context.ccColorScheme.surfaceVariant,
                context.ccColorScheme.surfaceVariant,
              ],
        ),
      ),
      child: Center(
        child: CcText(
          title ?? '',
          align: Alignment.center,
          textAlign: TextAlign.center,
          color:
              textColor ??
              (isEnable
                  ? context.ccColorScheme.onPrimary
                  : context.ccColorScheme.onSurfaceVariant),
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // If type is none or not enabled, return the base content directly
    if (interactionType == CcInteractionType.none || !isEnable) {
      return baseContent;
    }

    // Otherwise, wrap it in the interaction logic
    return CcInteractBtnWrapper(
      onTap: onTap ?? () {},
      useDebounce: useDebounce,
      isBouncing: interactionType == CcInteractionType.bounce,
      child: baseContent,
    );
  }
}
