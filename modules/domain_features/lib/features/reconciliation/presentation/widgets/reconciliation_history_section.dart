import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../get_x/reconciliation_controller.dart';
import 'reconciliation_history_card.dart';
import 'reconciliation_undo_sheet.dart';

class ReconciliationHistorySection extends StatelessWidget {
  const ReconciliationHistorySection({super.key, this.hasUndo = false});

  /// Offers undo on the latest record. Only for a closed cycle, where that
  /// record belongs to the current cycle: older ones stay as they are.
  final bool hasUndo;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();
    return Obx(() {
      if (controller.history.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CcText(
                el.tr(PrjLocaleKeys.reconciliation_history),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const CcSpaceSM(),
          for (final (index, record) in controller.history.indexed)
            ReconciliationHistoryCard(
              reconciliation: record,
              onUndo: hasUndo && index == 0 && !controller.hasSubmitting.value
                  ? () => ReconciliationUndoSheet.show(context)
                  : null,
            ),
        ],
      );
    });
  }
}
