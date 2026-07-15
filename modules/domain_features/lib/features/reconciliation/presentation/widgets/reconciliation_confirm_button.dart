import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/reconciliation_controller.dart';
import 'reconciliation_dialogs.dart';

class ReconciliationConfirmButton extends StatelessWidget {
  const ReconciliationConfirmButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();
    return Obx(() {
      final busy = controller.isSubmitting.value;
      final hasWarning = controller.unhandledCount.value > 0;
      return SizedBox(
        width: double.infinity,
        height: context.respDim(50),
        child: ElevatedButton(
          onPressed: busy || hasWarning ? null : () => _showConfirmDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.ccColorScheme.primary,
            alignment: Alignment.center,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: busy
              ? SizedBox(
                  width: context.respDim(20),
                  height: context.respDim(20),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.ccColorScheme.onPrimary,
                  ),
                )
              : Text(
                  el.tr(CcLocaleKeys.reconciliation_confirm),
                  textAlign: TextAlign.center,
                  style: context.ccTextTheme.labelMedium?.copyWith(
                    color: context.ccColorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
    });
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ReconciliationSuccessDialog(),
    );
  }
}
