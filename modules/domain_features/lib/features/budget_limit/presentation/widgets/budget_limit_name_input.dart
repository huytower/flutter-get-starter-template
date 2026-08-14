import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class BudgetLimitNameInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback onClear;
  final VoidCallback? onTap;

  const BudgetLimitNameInput({
    super.key,
    required this.controller,
    this.errorText,
    required this.onClear,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = context.ccTextTheme.bodyMedium?.copyWith(
      color: context.ccColorScheme.onSurface,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: context.respDim(40),
          child: TextField(
            controller: controller,
            maxLength: 30,
            style: textStyle,
            textAlignVertical: TextAlignVertical.center,
            cursorColor: context.ccColorScheme.primary,
            onTap: onTap,
            decoration: InputDecoration(
              counterText: '',
              hintText: el.tr(CcLocaleKeys.budget_name_hint),
              hintStyle: textStyle,
              filled: true,
              fillColor: context.ccColorScheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: context.brMd,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: context.brMd,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: context.brMd,
                borderSide: BorderSide(
                  color: context.ccColorScheme.primary.withOpacity(0.5),
                  width: context.respDim(1),
                ),
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? CcClearBtn(onTap: onClear)
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
              ),
            ),
          ),
        ],
      ],
    );
  }
}
