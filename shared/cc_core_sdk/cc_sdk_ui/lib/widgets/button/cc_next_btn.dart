import 'package:flutter/material.dart';

import '../../export_cc_sdk_ui.dart';

class CcNextBtn extends StatelessWidget {
  final VoidCallback onTap;
  final String? title;
  final bool isEnable;
  final CcInteractionType interactionType;
  final bool useDebounce;

  // Backward compatibility constructor (defaults to bounce)
  const CcNextBtn({
    super.key,
    required this.onTap,
    this.title,
    this.isEnable = true,
    this.useDebounce = true,
  }) : interactionType = CcInteractionType.bounce;

  // Private internal constructor
  const CcNextBtn._({
    required this.interactionType,
    required this.onTap,
    this.title,
    this.isEnable = true,
    this.useDebounce = true,
    super.key,
  });

  // Named constructors
  factory CcNextBtn.bouncing({
    required VoidCallback onTap,
    String? title,
    bool isEnable = true,
    bool useDebounce = true,
    Key? key,
  }) => CcNextBtn._(
    interactionType: CcInteractionType.bounce,
    onTap: onTap,
    title: title,
    isEnable: isEnable,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcNextBtn.simple({
    required VoidCallback onTap,
    String? title,
    bool isEnable = true,
    bool useDebounce = true,
    Key? key,
  }) => CcNextBtn._(
    interactionType: CcInteractionType.tap,
    onTap: onTap,
    title: title,
    isEnable: isEnable,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcNextBtn.static({String? title, bool isEnable = true, Key? key}) =>
      CcNextBtn._(
        interactionType: CcInteractionType.none,
        onTap: () {},
        title: title,
        isEnable: isEnable,
        useDebounce: false,
        key: key,
      );

  @override
  Widget build(BuildContext context) {
    final baseBtn = CcBaseBtn.static(
      isEnable: isEnable,
      title: title ?? 'Next',
      bgColor: isEnable
          ? [context.ccColorScheme.primary, context.ccColorScheme.primary]
          : null, // Fallback to surfaceVariant in CcBaseBtn
      textColor: isEnable
          ? context.ccColorScheme.onPrimary
          : null, // Fallback to onSurfaceVariant in CcBaseBtn
    );

    // If type is none or not enabled, return the base button directly
    if (interactionType == CcInteractionType.none || !isEnable) {
      return baseBtn;
    }

    // Otherwise, wrap it in the interaction logic
    return CcInteractBtnWrapper(
      onTap: onTap,
      useDebounce: useDebounce,
      isBouncing: interactionType == CcInteractionType.bounce,
      child: baseBtn,
    );
  }
}
