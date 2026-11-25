import 'dart:async';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../get_x/reconciliation_controller.dart';

export 'reconciliation_undo_sheet.dart';

class ReconciliationSuccessSheet extends StatefulWidget {
  const ReconciliationSuccessSheet({super.key, this.onDismiss});

  final VoidCallback? onDismiss;

  @override
  State<ReconciliationSuccessSheet> createState() =>
      _ReconciliationSuccessSheetState();
}

class _ReconciliationSuccessSheetState
    extends State<ReconciliationSuccessSheet> {
  Timer? _timer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    _timer?.cancel();

    // 1. Pop the dialog
    Navigator.of(context).pop();

    // 2. Trigger the callback to pop the page or handle completion
    widget.onDismiss?.call();
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
            maxHeight: size.height * 0.15,
          ),
          child: CcRewardCompletionBanner(
            message: el.tr(
              PrjLocaleKeys.reconciliation_success_message,
              namedArgs: {'count': count.toString()},
            ),
            onClose: _dismiss,
          ),
        ),
      ),
    );
  }
}
