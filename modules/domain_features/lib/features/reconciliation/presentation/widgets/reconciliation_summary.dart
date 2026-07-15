import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/money_format.dart';
import '../get_x/reconciliation_controller.dart';

class ReconciliationSummary extends StatelessWidget {
  const ReconciliationSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();
    final scheme = context.ccColorScheme;
    return Obx(() {
      final diff = controller.difference;
      final diffText = diff == 0
          ? el.tr(CcLocaleKeys.reconciliation_balanced)
          : '${diff < 0 ? '-' : '+'}${formatVndWithSymbol(diff.abs())}';
      return Column(
        children: [
          _summaryRow(
            context,
            el.tr(CcLocaleKeys.reconciliation_book_total),
            formatVndWithSymbol(controller.systemTotal.value),
          ),
          _summaryRow(
            context,
            el.tr(CcLocaleKeys.reconciliation_actual_total),
            formatVndWithSymbol(controller.actualTotal.value),
          ),
          const CcSpaceXS(),
          _summaryRow(
            context,
            el.tr(CcLocaleKeys.reconciliation_difference),
            diffText,
            color: diff == 0 ? scheme.primary : scheme.error,
          ),
        ],
      );
    });
  }

  Widget _summaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CcText(
            label,
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          CcText(
            value,
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
