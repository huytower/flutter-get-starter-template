import 'package:flutter/material.dart';

import 'language_selection_content_sheet.dart';
import '../../../../core/helper/adaptive_bottom_sheet.dart';

class LanguageSelectionSheet extends StatelessWidget {
  const LanguageSelectionSheet({super.key});

  static Future<Locale?> show(BuildContext context) {
    return showAdaptiveBottomSheet<Locale>(
      context: context,
      builder: (context) => const LanguageSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const LanguageSelectionContentSheet();
  }
}
