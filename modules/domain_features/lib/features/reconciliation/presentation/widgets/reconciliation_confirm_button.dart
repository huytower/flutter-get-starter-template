import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../transaction/presentation/widgets/transaction_submit_button.dart';
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
      final isEmpty = controller.balances.isEmpty;

      return TransactionSubmitButton(
        text: el.tr(CcLocaleKeys.reconciliation_confirm),
        isSubmitting: busy,
        isEnabled: !hasWarning && !isEmpty,
        onTap: () => _showConfirmDialog(context),
        activeColor: context.ccColorScheme.primary,
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
