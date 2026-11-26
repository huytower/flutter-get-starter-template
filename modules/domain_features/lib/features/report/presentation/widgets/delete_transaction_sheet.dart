import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../transaction/domain/usecases/delete_transaction_usecase.dart';

/// Asks before deleting a transaction from the report, then deletes it,
/// refreshes the screens that show it and tells the user how it went.
abstract final class DeleteTransactionSheet {
  static Future<void> confirmAndDelete(
    BuildContext context,
    TransactionEntity transaction,
  ) async {
    final confirmed = await CcConfirmSheet.show(
      context,
      icon: Icons.delete_outline_rounded,
      title: el.tr(PrjLocaleKeys.transaction_delete_title),
      message: el.tr(PrjLocaleKeys.transaction_delete_confirm_desc),
      confirmLabel: el.tr(PrjLocaleKeys.common_delete),
    );
    if (!confirmed) return;

    final result = await getIt<DeleteTransactionUseCase>().call(transaction);
    if (!context.mounted) return;
    if (result.isError()) {
      CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(
          result.tryGetError()?.message ?? PrjLocaleKeys.app_error_general,
        ),
      );
      return;
    }

    CcSnackBarHelper.showSuccessSnackBar(
      context: context,
      message: el.tr(PrjLocaleKeys.common_delete),
    );
    final refresh = getIt<FinancialRefreshProvider>();
    await refresh.refreshTransactions();
    await refresh.refreshWallets();
    await refresh.refreshReport(showLoading: false);
  }
}
