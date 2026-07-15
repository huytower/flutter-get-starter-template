import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class BudgetLimitNameInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback onClear;

  const BudgetLimitNameInput({
    super.key,
    required this.controller,
    this.errorText,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = context.ccTextTheme.bodyLarge?.copyWith(
      color: context.ccColorScheme.onSurface,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: context.respDim(50),
          child: TextField(
            controller: controller,
            maxLength: 30,
            style: textStyle,
            textAlignVertical: TextAlignVertical.center,
            cursorColor: context.ccColorScheme.primary,
            decoration: InputDecoration(
              counterText: '',
              hintText: el.tr(CcLocaleKeys.budget_name_hint),
              hintStyle: textStyle,
              filled: true,
              fillColor: context.ccColorScheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.respDim(12)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.respDim(12)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.respDim(12)),
                borderSide: BorderSide(
                  color: context.ccColorScheme.primary.withOpacity(0.5),
                  width: context.respDim(1),
                ),
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? CcIconButton.bouncing(
                      icon: Icon(
                        Icons.cancel_rounded,
                        size: context.respIconSize(baseSize: 20),
                        color: context.ccColorScheme.onSurfaceVariant,
                      ),
                      onTap: onClear,
                    )
                  : null,
            ),
          ),
        ),
        if (errorText != null) ...[
          const CcSpaceXS(),
          Padding(
            padding: EdgeInsets.only(left: context.respPadding(4)),
            child: CcText(
              errorText!,
              textStyle: context.ccTextTheme.labelSmall?.copyWith(
                color: context.ccColorScheme.error,
                fontSize: context.respFontSize(11),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
