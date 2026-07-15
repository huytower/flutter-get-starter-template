import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/reconciliation_controller.dart';
import 'reconciliation_dialogs.dart';
import 'reconciliation_history_card.dart';

class ReconciliationHistorySection extends StatelessWidget {
  const ReconciliationHistorySection({super.key});

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
                el.tr(CcLocaleKeys.reconciliation_history),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showUndoDialog(context),
                icon: const Icon(Icons.undo, size: 18),
                label: Text(el.tr(CcLocaleKeys.reconciliation_undo)),
              ),
            ],
          ),
          const CcSpaceSM(),
          ...controller.history.map(
            (r) => ReconciliationHistoryCard(reconciliation: r),
          ),
        ],
      );
    });
  }

  void _showUndoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const ReconciliationUndoDialog(),
    );
  }
}
