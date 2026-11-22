import 'package:flutter/material.dart';

import '../../../../core/presentation/helper/adaptive_bottom_sheet.dart';
import 'language_selection_content_sheet.dart';

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
