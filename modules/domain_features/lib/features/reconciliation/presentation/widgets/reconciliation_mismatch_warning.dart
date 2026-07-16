import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/reconciliation_controller.dart';

class ReconciliationMismatchWarning extends StatelessWidget {
  const ReconciliationMismatchWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();
    return Obx(() {
      final count = controller.unhandledCount.value;
      if (count == 0) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.ccColorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.ccColorScheme.error.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: context.ccColorScheme.error,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CcText(
                el.tr(
                  CcLocaleKeys.reconciliation_mismatch_warning,
                  namedArgs: {'count': count.toString()},
                ),
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  color: context.ccColorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
