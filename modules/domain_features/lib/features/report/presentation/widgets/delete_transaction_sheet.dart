import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../get_x/report_controller.dart';

class DeleteTransactionSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CcText(
            el.tr(CcLocaleKeys.transaction_delete_title),
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const CcSpaceMD(),
          CcText(
            el.tr(CcLocaleKeys.transaction_delete_confirm_desc),
            textStyle: context.ccTextTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const CcSpaceLG(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: context.respPadding(CcPaddingParams.SPACE_MD),
                    ),
                  ),
                  child: CcText(el.tr(CcLocaleKeys.common_cancel)),
                ),
              ),
              const CcSpaceMD(),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _delete(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.ccColorScheme.error,
                    foregroundColor: context.ccColorScheme.onError,
                    padding: EdgeInsets.symmetric(
                      vertical: context.respPadding(CcPaddingParams.SPACE_MD),
                    ),
                  ),
                  child: CcText(el.tr(CcLocaleKeys.common_delete)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final repo = getIt<TransactionRepository>();
    final result = await repo.deleteTransaction(transaction.id);

    if (context.mounted) {
      if (result.isSuccess()) {
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
