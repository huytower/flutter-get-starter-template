import 'package:flutter/material.dart';

import 'language_selection_content_sheet.dart';

class LanguageSelectionSheet extends StatelessWidget {
  const LanguageSelectionSheet({super.key});

  static Future<Locale?> show(BuildContext context) {
    return showModalBottomSheet<Locale>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const LanguageSelectionContentSheet();
  }
}
