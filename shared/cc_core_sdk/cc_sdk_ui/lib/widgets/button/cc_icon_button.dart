import 'package:flutter/material.dart';

import '../../export_cc_sdk_ui.dart';

/// A standardized Icon Button that supports the project's interaction patterns (bounce/debounce).
class CcIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final Color? bgColor;
  final double? height, width;
  final CcInteractionType interactionType;
  final bool useDebounce;
  final String? tooltip;
  final bool isEnable;

  const CcIconButton({
    required this.icon,
    required this.onTap,
    this.bgColor,
    this.height,
    this.width,
    this.useDebounce = true,
    this.tooltip,
    this.isEnable = true,
    super.key,
  }) : interactionType = CcInteractionType.bounce;

  const CcIconButton._({
    required this.icon,
    required this.interactionType,
    this.onTap,
    this.bgColor,
    this.height,
    this.width,
    this.useDebounce = true,
    this.tooltip,
    this.isEnable = true,
    super.key,
  });

  factory CcIconButton.bouncing({
    required Widget icon,
    required VoidCallback onTap,
    Color? bgColor,
    double? height,
    double? width,
    bool useDebounce = true,
    String? tooltip,
    bool isEnable = true,
    Key? key,
  }) => CcIconButton._(
    icon: icon,
    interactionType: CcInteractionType.bounce,
    onTap: onTap,
    bgColor: bgColor,
    height: height,
    width: width,
    useDebounce: useDebounce,
    tooltip: tooltip,
    isEnable: isEnable,
    key: key,
  );

  factory CcIconButton.simple({
    required Widget icon,
    required VoidCallback onTap,
    Color? bgColor,
    double? height,
    double? width,
    bool useDebounce = true,
    String? tooltip,
    bool isEnable = true,
    Key? key,
  }) => CcIconButton._(
    icon: icon,
    interactionType: CcInteractionType.tap,
    onTap: onTap,
    bgColor: bgColor,
    height: height,
    width: width,
    useDebounce: useDebounce,
    tooltip: tooltip,
    isEnable: isEnable,
    key: key,
  );

  @override
  Widget build(BuildContext context) {
    final double defaultSize = context.respDim(40.0);

    final Widget button = Opacity(
      opacity: isEnable ? 1.0 : 0.5,
      child: Container(
        width: width ?? defaultSize,
        height: height ?? defaultSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: icon,
      ),
    );

    final Widget interactiveButton = CcInteractBtnWrapper(
      onTap: onTap ?? () {},
      useDebounce: useDebounce,
      isBouncing: interactionType == CcInteractionType.bounce,
      isEnable: isEnable,
      child: button,
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: interactiveButton);
    }

    return interactiveButton;
  }
}
