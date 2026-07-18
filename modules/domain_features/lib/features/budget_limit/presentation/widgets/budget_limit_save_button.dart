import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class BudgetLimitSaveButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const BudgetLimitSaveButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: SizedBox(
          width: double.infinity,
          height: context.respDim(40),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.ccColorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: CcText(
              el.tr(CcLocaleKeys.common_save),
              align: Alignment.center,
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: context.ccColorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
