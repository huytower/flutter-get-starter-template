import 'package:flutter/material.dart';

import 'language_selection_dialog_content.dart';

class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  static Future<Locale?> show(BuildContext context) {
    return showModalBottomSheet<Locale>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const LanguageSelectionDialogContent();
  }
}
