import 'package:flutter/material.dart';

import '../../export_cc_sdk_ui.dart';

class CcBackBtn extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onTap;
  final CcInteractionType interactionType;
  final bool useDebounce;

  // Backward compatibility constructor (defaults to bounce)
  const CcBackBtn({
    required this.onTap,
    this.icon,
    super.key,
    this.useDebounce = true,
  }) : interactionType = CcInteractionType.bounce;

  // Private internal constructor
  const CcBackBtn._({
    required this.interactionType,
    this.onTap,
    this.icon,
    this.useDebounce = true,
    super.key,
  });

  // Named constructors
  factory CcBackBtn.bouncing({
    required VoidCallback onTap,
    IconData? icon,
    bool useDebounce = true,
    Key? key,
  }) => CcBackBtn._(
    interactionType: CcInteractionType.bounce,
    onTap: onTap,
    icon: icon,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcBackBtn.simple({
    required VoidCallback onTap,
    IconData? icon,
    bool useDebounce = true,
    Key? key,
  }) => CcBackBtn._(
    interactionType: CcInteractionType.tap,
    onTap: onTap,
    icon: icon,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcBackBtn.static({IconData? icon, Key? key}) => CcBackBtn._(
    interactionType: CcInteractionType.none,
    icon: icon,
    useDebounce: false,
    key: key,
  );

  @override
  Widget build(BuildContext context) {
    final baseIcon = Padding(
      padding: EdgeInsets.all(context.respPadding(4)),
      child: CcIcon(
        icon: icon ?? Icons.arrow_back,
        size: context.respIconSize(baseSize: 20.0),
        align: Alignment.center,
        color: context.ccColorScheme.onSurface,
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
