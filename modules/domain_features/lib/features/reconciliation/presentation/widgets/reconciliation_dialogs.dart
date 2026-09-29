import 'dart:async';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/reconciliation_controller.dart';

class ReconciliationSuccessDialog extends StatefulWidget {
  const ReconciliationSuccessDialog({super.key, this.onDismiss});

  final VoidCallback? onDismiss;

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

class ReconciliationUndoSheet extends StatelessWidget {
  const ReconciliationUndoSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ReconciliationUndoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReconciliationController>();
    final scheme = context.ccColorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(context.respDim(14)),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.undo_rounded,
                  color: scheme.primary,
                  size: context.respIconSize(baseSize: 28),
                ),
              ),
            ),
            const CcSpaceMD(),
            CcText(
              el.tr(CcLocaleKeys.reconciliation_undo_title),
              align: Alignment.center,
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const CcSpaceSM(),
            CcText(
              el.tr(CcLocaleKeys.reconciliation_undo_confirm),
              align: Alignment.center,
              maxLines: 5,
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const CcSpaceLG(),
            Row(
              children: [
                Expanded(
                  child: CcBaseBtn(
                    title: el.tr(CcLocaleKeys.common_cancel),
                    bgColor: [
                      scheme.surfaceContainerHighest,
                      scheme.surfaceContainerHighest,
                    ],
                    textColor: scheme.onSurface,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const CcSpaceMD(),
                Expanded(
                  child: CcBaseBtn(
                    title: el.tr(CcLocaleKeys.reconciliation_undo),
                    bgColor: [scheme.primary, scheme.primaryContainer],
                    textColor: scheme.onPrimary,
                    onTap: () async {
                      if (controller.isSubmitting.value) return;
                      Navigator.of(context).pop();
                      final error = await controller.undoLast();
                      if (!context.mounted) return;
                      if (error != null) {
                        CcSnackBarHelper.showErrorSnackBar(
                          context: context,
                          message: error,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
