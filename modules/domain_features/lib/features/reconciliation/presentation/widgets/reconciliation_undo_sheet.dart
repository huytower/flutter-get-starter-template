import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../get_x/reconciliation_controller.dart';

/// Asks before undoing the last reconciliation, then undoes it.
abstract final class ReconciliationUndoSheet {
  static Future<void> show(BuildContext context) async {
    final controller = Get.find<ReconciliationController>();
    final confirmed = await CcConfirmSheet.show(
      context,
      icon: Icons.undo_rounded,
      title: el.tr(PrjLocaleKeys.reconciliation_undo_title),
      message: el.tr(PrjLocaleKeys.reconciliation_undo_confirm),
      confirmLabel: el.tr(PrjLocaleKeys.reconciliation_undo),
      tone: CcConfirmTone.primary,
    );
    if (!confirmed || controller.hasSubmitting.value) return;
    final error = await controller.undoLast();
    if (error == null || !context.mounted) return;
    CcSnackBarHelper.showErrorSnackBar(context: context, message: error);
  }
}

