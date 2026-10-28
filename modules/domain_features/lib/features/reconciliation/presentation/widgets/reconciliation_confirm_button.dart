import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../transaction/presentation/widgets/transaction_submit_button.dart';
import '../get_x/reconciliation_controller.dart';

class ReconciliationConfirmButton extends StatelessWidget {
  const ReconciliationConfirmButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();
    return Obx(() {
      final busy = controller.isSubmitting.value;

      return TransactionSubmitButton(
        text: el.tr(CcLocaleKeys.reconciliation_confirm),
        isSubmitting: busy,
        isEnabled: controller.canReconcile,
        onTap: () => controller.confirmReconciliation(context),
        activeColor: context.ccColorScheme.primary,
        widthFactor: 0.5,
        height: context.respDim(40),
        textStyle: context.ccTextTheme.bodyMedium,
        leadingIcon: Icons.handshake_outlined,
        leadingIconSize: 16,
      );
    });
  }
}
