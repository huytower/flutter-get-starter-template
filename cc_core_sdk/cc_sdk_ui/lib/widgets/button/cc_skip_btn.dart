import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../export_cc_sdk_ui.dart';

class CcSkipBtn extends StatelessWidget {
  final VoidCallback onTap;
  final CcInteractionType interactionType;
  final bool useDebounce;

  // Backward compatibility constructor (defaults to bounce)
  const CcSkipBtn({super.key, required this.onTap, this.useDebounce = true})
    : interactionType = CcInteractionType.bounce;

  // Private internal constructor
  const CcSkipBtn._({
    required this.interactionType,
    required this.onTap,
    this.useDebounce = true,
    super.key,
  });

  // Named constructors
  factory CcSkipBtn.bouncing({
    required VoidCallback onTap,
    bool useDebounce = true,
    Key? key,
  }) => CcSkipBtn._(
    interactionType: CcInteractionType.bounce,
    onTap: onTap,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcSkipBtn.simple({
    required VoidCallback onTap,
    bool useDebounce = true,
    Key? key,
  }) => CcSkipBtn._(
    interactionType: CcInteractionType.tap,
    onTap: onTap,
    useDebounce: useDebounce,
    key: key,
  );

  factory CcSkipBtn.static({Key? key}) => CcSkipBtn._(
    interactionType: CcInteractionType.none,
    onTap: () {},
    useDebounce: false,
    key: key,
  );

  @override
  Widget build(BuildContext context) {
    final baseContent = Padding(
      padding: EdgeInsets.only(
        right: context.respPadding(CcPaddingParams.PAGE_LG),
      ),
      child: Container(
        width: context.respIconSize(baseSize: 103.0),
        height: context.respIconSize(baseSize: 76.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(
            context.respDim(CcPaddingParams.DESC_SM),
          ),
        ),
        child: Center(
          child: CcText(
            el.tr(CcLocaleKeys.common_skip),
            align: Alignment.center,
            textAlign: TextAlign.center,
            color: context.ccColorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // If type is none, return the base content directly
    if (interactionType == CcInteractionType.none) {
      return baseContent;
    }

    // Otherwise, wrap it in the interaction logic
    return CcInteractBtnWrapper(
      onTap: onTap,
      useDebounce: useDebounce,
      isBouncing: interactionType == CcInteractionType.bounce,
      child: baseContent,
    );
  }
}
