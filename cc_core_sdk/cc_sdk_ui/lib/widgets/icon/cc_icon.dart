import 'package:flutter/material.dart';

import '../../export_cc_sdk_ui.dart';

class CcIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final Alignment? align;

  const CcIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.align,
  });

  @override
  Widget build(BuildContext context) => Align(
    alignment: align ?? Alignment.center,
    child: Padding(
      padding: EdgeInsets.all(context.respPadding(8)),
      child: Icon(
        icon,
        size: size ?? context.respIconSize(baseSize: 20.0),
        color: color ?? context.ccColorScheme.onSurface,
      ),
    ),
  );
}

class CcMediaIcon extends StatelessWidget {
  final bool isVisible;
  final Color color;
  final IconData icon;
  final double? iconSize;
  final VoidCallback? onTap;
  final CcInteractionType interactionType;
  final bool useDebounce;

  // Backward compatibility constructor (defaults to bounce)
  const CcMediaIcon({
    super.key,
    this.onTap,
    required this.isVisible,
    required this.icon,
    this.iconSize,
    required this.color,
    this.useDebounce = true,
  }) : interactionType = CcInteractionType.bounce;

  // Private internal constructor
  const CcMediaIcon._({
    required this.interactionType,
    this.onTap,
    required this.isVisible,
    required this.icon,
    this.iconSize,
    required this.color,
    this.useDebounce = true,
    super.key,
  });

  // Named constructors
  factory CcMediaIcon.bouncing({
    VoidCallback? onTap,
    required bool isVisible,
    required IconData icon,
    double? iconSize,
    required Color color,
    bool useDebounce = true,
    Key? key,
  }) => CcMediaIcon._(
    interactionType: CcInteractionType.bounce,
    onTap: onTap,
    isVisible: isVisible,
    icon: icon,
    iconSize: iconSize,
    color: color,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcMediaIcon.simple({
    VoidCallback? onTap,
    required bool isVisible,
    required IconData icon,
    double? iconSize,
    required Color color,
    bool useDebounce = true,
    Key? key,
  }) => CcMediaIcon._(
    interactionType: CcInteractionType.tap,
    onTap: onTap,
    isVisible: isVisible,
    icon: icon,
    iconSize: iconSize,
    color: color,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcMediaIcon.static({
    required bool isVisible,
    required IconData icon,
    double? iconSize,
    required Color color,
    Key? key,
  }) => CcMediaIcon._(
    interactionType: CcInteractionType.none,
    isVisible: isVisible,
    icon: icon,
    iconSize: iconSize,
    color: color,
    useDebounce: false,
    key: key,
  );

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox(width: 35);
    }

    final baseIcon = CcIcon(
      icon: icon,
      size: iconSize ?? context.respIconSize(baseSize: 20.0),
      color: color,
      align: Alignment.center,
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
