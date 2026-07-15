import 'dart:async';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/reconciliation_controller.dart';

class ReconciliationSuccessDialog extends StatefulWidget {
  const ReconciliationSuccessDialog({super.key});

  @override
  State<ReconciliationSuccessDialog> createState() =>
      _ReconciliationSuccessDialogState();
}

class _ReconciliationSuccessDialogState
    extends State<ReconciliationSuccessDialog> {
  Timer? _timer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_dismissed) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _timer?.cancel();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();
    final count = controller.history.length;
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size.width * 0.9,
            maxHeight: size.height * 0.2,
          ),
          child: CcRewardCompletionBanner(
            message: el.tr(
              CcLocaleKeys.reconciliation_success_message,
              namedArgs: {'count': count.toString()},
            ),
            onClose: _dismiss,
          ),
        ),
      ),
    );
  }
}

class ReconciliationUndoDialog extends StatelessWidget {
  const ReconciliationUndoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();

    return AlertDialog(
      title: Text(el.tr(CcLocaleKeys.reconciliation_undo_title)),
      content: Text(el.tr(CcLocaleKeys.reconciliation_undo_confirm)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(el.tr(CcLocaleKeys.common_cancel)),
        ),
        TextButton(
          onPressed: () async {
            if (controller.isSubmitting.value) return;
            Navigator.pop(context);
            final error = await controller.undoLast();
            if (!context.mounted) return;
            if (error != null) {
              CcSnackBarHelper.showErrorSnackBar(
                context: context,
                message: error,
              );
            }
          },
          child: Text(el.tr(CcLocaleKeys.reconciliation_undo)),
        ),
      ],
    );
  }
}
