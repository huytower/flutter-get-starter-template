import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/presentation/helper/quick_amount_values.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

/// The app's money keypad: `CcKeypadPanel` with the app's translations and
/// quick amounts labelled in the primary currency (Momo style chips above the
/// keys).
class MoneyKeypadPanel extends StatelessWidget {
  const MoneyKeypadPanel({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
    required this.onClear,
    this.onCopy,
    this.suggestions = const [],
    this.onSuggestion,
    required this.onDone,
    required this.activeColor,
  });

  final ValueChanged<String> onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback? onCopy;

  /// Quick-amount suggestions; tapping one fires [onSuggestion].
  final List<int> suggestions;
  final ValueChanged<int>? onSuggestion;

  final VoidCallback onDone;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return CcKeypadPanel<int>(
      onKeyPress: onKeyPress,
      onDelete: onDelete,
      onClear: onClear,
      onCopy: onCopy,
      onDone: onDone,
      activeColor: activeColor,
      labels: CcKeypadLabels(
        clear: el.tr(PrjLocaleKeys.common_clear),
        copy: el.tr(PrjLocaleKeys.common_copy),
        done: el.tr(PrjLocaleKeys.common_done),
      ),
      suggestions: QuickAmountValues.from(suggestions),
      onSuggestion: onSuggestion,
    );
  }
}
