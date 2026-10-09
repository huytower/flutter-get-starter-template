import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../get_x/reconciliation_controller.dart';

class ReconciliationSummary extends StatelessWidget {
  const ReconciliationSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();
    final walletController = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(getIt<WalletController>());
    final scheme = context.ccColorScheme;

    return Obx(() {
      final currencyCode = walletController.currencyCode.value;
      final diff = controller.difference;
      final diffText = diff == 0
          ? el.tr(CcLocaleKeys.reconciliation_balanced)
          : '${diff < 0 ? '-' : '+'}${formatShortCurrencyWithSymbol(diff.abs(), currencyCode: currencyCode)}';
      return Column(
        children: [
          _summaryRow(
            context,
            el.tr(CcLocaleKeys.reconciliation_book_total),
            formatShortCurrencyWithSymbol(
              controller.systemTotal.value,
              currencyCode: currencyCode,
            ),
          ),
          _summaryRow(
            context,
            el.tr(CcLocaleKeys.reconciliation_actual_total),
            formatShortCurrencyWithSymbol(
              controller.actualTotal.value,
              currencyCode: currencyCode,
            ),
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
