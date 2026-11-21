import 'package:flutter/material.dart';

import '../../../../core/helper/adaptive_bottom_sheet.dart';
import 'reconciliation_guide_content_sheet.dart';

/// Bottom sheet explaining what reconciliation is and how to do it.
class ReconciliationGuideSheet extends StatelessWidget {
  const ReconciliationGuideSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAdaptiveBottomSheet<void>(
      context: context,
      backgroundColor: null,
      // Two columns of guide rows need more room than a plain list sheet.
      tabletMaxWidth: 840,
      builder: (context) => const ReconciliationGuideSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const ReconciliationGuideContentSheet();
  }
}
