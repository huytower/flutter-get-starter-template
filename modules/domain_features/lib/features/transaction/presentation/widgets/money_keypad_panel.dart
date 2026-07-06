import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'quick_numeric_keypad.dart';

class MoneyKeypadPanel extends StatelessWidget {
  final void Function(String) onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback onClear;

  /// Kept for API compatibility with receipt/transfer forms; no longer used
  /// inside this widget (quick-amount chips live in the inline form row).
  final void Function(int)? onSuggestion;

  final VoidCallback onDone;
  final Color activeColor;

  const MoneyKeypadPanel({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
    required this.onClear,
    this.onSuggestion,
    required this.onDone,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onDone,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.respPadding(CcPaddingParams.PAGE_XS),
                    horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
                  ),
                  child: CcText(
                    'Xong',
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      color: activeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: context.respFontSize(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
          QuickNumericKeypad(
            onKeyPress: onKeyPress,
            onDelete: onDelete,
            onClear: onClear,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }
}
