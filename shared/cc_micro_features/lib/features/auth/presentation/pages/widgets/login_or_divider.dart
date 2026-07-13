import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class LoginOrDivider extends StatelessWidget {
  const LoginOrDivider({
    super.key,
    this.orText,
  });

  /// Semantic token for the divider label.
  /// Defaults to a plain English token so this project-blind widget never
  /// depends on the `message` module (follows `CcNextBtn.title` pattern).
  final String? orText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: context.ccColorScheme.outlineVariant,
            thickness: context.respDim(1),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
          ),
          child: CcText(
            orText ?? 'OR',
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: context.ccColorScheme.outlineVariant,
            thickness: context.respDim(1),
          ),
        ),
      ],
    );
  }
}
