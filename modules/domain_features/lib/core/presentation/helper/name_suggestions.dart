import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/widgets.dart';

/// Quick-pick name suggestions for the "add" sheets (wallet, investment,
/// liability), shown by `PrjSuggestedNameField` as chips.
///
/// One list is one translation whose items are separated by `|`, so a locale
/// can change its list without a code change. Each feature maps its own
/// types / categories to those keys (e.g. `WalletNameSuggestions`).
abstract final class NameSuggestions {
  static const String _separator = '|';

  /// The localized suggestions under [key]; empty when [key] is null.
  static List<CcQuickValue<String>> fromKey(String? key) {
    if (key == null) return const [];
    return [
      for (final raw in el.tr(key).split(_separator))
        if (raw.trim().isNotEmpty)
          CcQuickValue(value: raw.trim(), label: raw.trim()),
    ];
  }

  /// Puts [name] in [controller], cursor at the end.
  static void apply(TextEditingController controller, String name) {
    controller.value = TextEditingValue(
      text: name,
      selection: TextSelection.collapsed(offset: name.length),
    );
  }

  /// Empties [controller] when it holds one of the suggestions under [key]
  /// (picked for the type / category being left); a typed name is kept.
  static void clearIfSuggested(TextEditingController controller, String? key) {
    final name = controller.text.trim();
    if (name.isEmpty) return;
    if (fromKey(key).any((suggestion) => suggestion.value == name)) {
      controller.clear();
    }
  }
}
