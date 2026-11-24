import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'language_selection_content_sheet.dart';

class LanguageSelectionSheet extends StatelessWidget {
  const LanguageSelectionSheet({super.key});

  static Future<Locale?> show(BuildContext context) {
    return CcAdaptiveBottomSheet.show<Locale>(
      context: context,
      builder: (context) => const LanguageSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const LanguageSelectionContentSheet();
  }
}
