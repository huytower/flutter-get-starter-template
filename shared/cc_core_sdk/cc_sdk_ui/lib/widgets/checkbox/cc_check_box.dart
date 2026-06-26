import 'package:flutter/material.dart';

import '../../export_cc_sdk_ui.dart';

class CcCheckBox extends StatelessWidget {
  const CcCheckBox({
    super.key,
    required this.isChecked,
    required this.onChanged,
    this.interactionType = CcInteractionType.bounce,
    this.useDebounce = true,
  });

  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final CcInteractionType interactionType;
  final bool useDebounce;

  @override
  Widget build(BuildContext context) {
    final baseContent = Container(
      width: context.respIconSize(baseSize: 24.0),
      height: context.respIconSize(baseSize: 24.0),
      decoration: BoxDecoration(
        color: isChecked ? context.ccColorScheme.primary : Colors.transparent,
        border: Border.all(
          color: isChecked
              ? context.ccColorScheme.primary
              : context.ccColorScheme.outline,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(CcCircularParams.RADIUS_XS),
      ),
      child: isChecked
          ? Icon(
              Icons.check,
              size: context.respIconSize(baseSize: 16.0),
              color: context.ccColorScheme.onPrimary,
            )
          : null,
    );

    if (interactionType == CcInteractionType.none) {
      return baseContent;
    }

    return CcInteractBtnWrapper(
      onTap: () => onChanged(!isChecked),
      useDebounce: useDebounce,
      isBouncing: interactionType == CcInteractionType.bounce,
      child: baseContent,
    );
  }
}
