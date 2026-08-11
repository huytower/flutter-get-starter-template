import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import 'cc_quick_amount_chips.dart';
import 'quick_numeric_keypad.dart';

class MoneyKeypadPanel extends StatelessWidget {
  final void Function(String) onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback onClear;

  /// Quick-amount suggestions (Momo style) shown as a chip strip above the
  /// keypad; tapping one fires [onSuggestion].
  final List<int> suggestions;
  final void Function(int)? onSuggestion;

  final VoidCallback onDone;
  final Color activeColor;

  const MoneyKeypadPanel({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
    required this.onClear,
    this.suggestions = const [],
    this.onSuggestion,
    required this.onDone,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    // Hide soft keyboard when this custom keypad panel is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        currentFocus.focusedChild?.unfocus();
      }
    });

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: context.ccColorScheme.outlineVariant.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CcSymmetricPadding(
            vertical: CcPaddingParams.SPACE_XS,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CcQuickAmountChips(
                    amounts: suggestions,
                    onSelected: (val) => onSuggestion?.call(val),
                    activeColor: activeColor,
                    padding: EdgeInsets.only(
                      left: context.respPadding(CcPaddingParams.SPACE_SM),
                    ),
                  ),
                ),
                CcInkWell(
                  onTap: onDone,
                  child: CcSymmetricPadding(
                    horizontal: CcPaddingParams.SPACE_XL,
                    child: CcText(
                      el.tr(CcLocaleKeys.common_done),
                      textStyle: context.ccTextTheme.labelMedium?.copyWith(
                        color: activeColor,
                        fontWeight: CcTypographyParams.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
