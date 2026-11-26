import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/reconciliation_availability_entity.dart';
import '../get_x/reconciliation_controller.dart';
import 'reconciliation_guide_content_sheet.dart';

/// Bottom sheet explaining what reconciliation is and how to do it.
class ReconciliationGuideSheet extends StatelessWidget {
  const ReconciliationGuideSheet({super.key, this.cycle});

  /// The user's current audit cycle, shown in the "when" row.
  final ReconciliationAvailabilityEntity? cycle;

  /// Shows the guide with the current audit cycle, taken from the
  /// reconciliation page's controller when [cycle] is not given.
  static Future<void> show(
    BuildContext context, {
    ReconciliationAvailabilityEntity? cycle,
  }) {
    final shown =
        cycle ??
        (Get.isRegistered<ReconciliationController>()
            ? Get.find<ReconciliationController>().cycle.value
            : null);
    return CcAdaptiveBottomSheet.show<void>(
      context: context,
      backgroundColor: null,
      // Two columns of guide rows need more room than a plain list sheet.
      tabletMaxWidth: 840,
      builder: (context) => ReconciliationGuideSheet(cycle: shown),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReconciliationGuideContentSheet(cycle: cycle);
  }
}
