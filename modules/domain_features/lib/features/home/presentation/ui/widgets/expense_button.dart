import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class ExpenseButton extends StatelessWidget {
  const ExpenseButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CcBaseBtn(
      onTap: onTap,
      title: el.tr(CcLocaleKeys.common_expense),
      width: context.respDim(80),
      height: context.respDim(36),
      colorsGradient: [
        context.ccColorScheme.primary,
        context.ccColorScheme.primaryContainer,
      ],
      textColor: context.ccColorScheme.onPrimary,
      borderRadius: BorderRadius.circular(8),
    );
  }
}
