import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../get_x/report_controller.dart';

class DeleteTransactionSheet extends StatefulWidget {
  const DeleteTransactionSheet({
    super.key,
    required this.transaction,
  });

  final TransactionEntity transaction;

  static Future<void> show(BuildContext context, TransactionEntity transaction) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DeleteTransactionSheet(transaction: transaction),
    );
  }

  @override
  State<DeleteTransactionSheet> createState() =>
      _DeleteTransactionSheetState();
}

class _DeleteTransactionSheetState extends State<DeleteTransactionSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                  color: scheme.error.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: scheme.error,
                  size: context.respIconSize(baseSize: 28),
                ),
              ),
            ),
            const CcSpaceMD(),
            CcText(
              el.tr(CcLocaleKeys.transaction_delete_title),
              align: Alignment.center,
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const CcSpaceSM(),
            CcText(
              el.tr(CcLocaleKeys.transaction_delete_confirm_desc),
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
                    isEnable: !_isLoading,
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
                    title: _isLoading
                        ? null
                        : el.tr(CcLocaleKeys.common_delete),
                    isEnable: !_isLoading,
                    bgColor: [scheme.error, scheme.error],
                    textColor: scheme.onError,
                    onTap: () async {
                      setState(() => _isLoading = true);
                      try {
                        await _delete(context);
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (_isLoading) ...[
              const CcSpaceMD(),
              const Center(child: CcLoadingIconWidget()),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final repo = getIt<TransactionRepository>();
    final result = await repo.deleteTransaction(widget.transaction.id);

    if (context.mounted) {
      if (result.isSuccess()) {
        Navigator.of(context).pop();
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.common_delete),
        );
        if (Get.isRegistered<ReportController>()) {
          await Get.find<ReportController>().load(showLoading: false);
        }
      } else {
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: result.tryGetError()?.message ?? el.tr(CcLocaleKeys.app_error_general),
        );
      }
    }
  }
}
