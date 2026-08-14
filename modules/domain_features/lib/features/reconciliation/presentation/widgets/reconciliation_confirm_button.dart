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
      return DecoratedBox(
        decoration: BoxDecoration(
          color: context.ccColorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(
            Icons.check_circle_outline,
            color: context.ccColorScheme.primary,
          ),
          title: CcText(
            el.tr(CcLocaleKeys.reconciliation_confirm),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: busy || hasWarning ? null : () => _showConfirmDialog(context),
        ),
      );
    });
  }

  void _showConfirmDialog(BuildContext context) async {
    final controller = Get.find<ReconciliationController>();
    final error = await controller.performReconciliation();

    if (!context.mounted) return;

    if (error != null) {
      CcSnackBarHelper.showErrorSnackBar(context: context, message: error);
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ReconciliationSuccessDialog(
          onDismiss: () => Navigator.of(context).pop(),
        ),
      );
    }
  }
}
