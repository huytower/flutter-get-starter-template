import 'package:flutter/material.dart';

import 'reconciliation_guide_content_sheet.dart';

/// Bottom sheet explaining what reconciliation is and how to do it.
class ReconciliationGuideSheet extends StatelessWidget {
  const ReconciliationGuideSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReconciliationGuideSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const ReconciliationGuideContentSheet();
  }
}
