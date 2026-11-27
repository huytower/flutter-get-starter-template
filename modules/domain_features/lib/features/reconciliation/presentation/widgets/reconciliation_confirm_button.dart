import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../get_x/reconciliation_controller.dart';
import 'reconciliation_success_sheet.dart';

class ReconciliationConfirmButton extends StatelessWidget {
  const ReconciliationConfirmButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();
    return Obx(() {
      final busy = controller.hasSubmitting.value;

      return CcSubmitButton(
        text: el.tr(PrjLocaleKeys.reconciliation_confirm),
        hasSubmitting: busy,
        hasEnabled: controller.canReconcile,
        onTap: () => _confirm(context, controller),
        activeColor: context.ccColorScheme.primary,
        widthFactor: 0.5,
        height: context.respDim(40),
        textStyle: context.ccTextTheme.bodyMedium,
        leadingIcon: Icons.handshake_outlined,
        leadingIconSize: 16,
      );
    });
  }

  Future<void> _confirm(
    BuildContext context,
    ReconciliationController controller,
  ) async {
    // Confirming closes the cycle, which takes this button off the page, so
    // the sheets and the page pop go through the navigator.
    final navigator = Navigator.of(context);
    final error = await controller.performReconciliation();
    if (!navigator.mounted) return;
    if (error != null) {
      CcSnackBarHelper.showErrorSnackBar(
        context: navigator.context,
        message: error,
      );
      return;
    }
    await showDialog<void>(
      context: navigator.context,
      barrierDismissible: false,
      builder: (_) => ReconciliationSuccessSheet(onDismiss: navigator.pop),
    );
  }
}
