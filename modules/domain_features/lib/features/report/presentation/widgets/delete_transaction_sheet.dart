import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/repositories/transaction_repository.dart';

class DeleteTransactionSheet extends StatelessWidget {
  const DeleteTransactionSheet({super.key, required this.transaction});

  final TransactionEntity transaction;

  static Future<Result<Unit, CcFailure>?> show(
    BuildContext context,
    TransactionEntity transaction,
  ) {
    return CcAdaptiveBottomSheet.show<Result<Unit, CcFailure>>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: context.brXl),
      builder: (_) => DeleteTransactionSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    // Scrolls in landscape (short window) instead of overflowing.
    return CcLandscapeScrollable(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_LG),
          ),
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
                el.tr(PrjLocaleKeys.transaction_delete_title),
                align: Alignment.center,
                textAlign: TextAlign.center,
                textStyle: context.ccTextTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const CcSpaceSM(),
              CcText(
                el.tr(PrjLocaleKeys.transaction_delete_confirm_desc),
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
                    child: CcBaseButton(
                      title: el.tr(PrjLocaleKeys.common_cancel),
                      backgroundColor: [
                        scheme.surfaceContainerHighest,
                        scheme.surfaceContainerHighest,
                      ],
                      textColor: scheme.onSurface,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const CcSpaceMD(),
                  Expanded(
                    child: CcBaseButton(
                      title: el.tr(PrjLocaleKeys.common_delete),
                      backgroundColor: [scheme.error, scheme.error],
                      textColor: scheme.onError,
                      onTap: () async {
                        Navigator.of(context).pop();
                        final result = await _delete(context);
                        if (result.isError() && context.mounted) {
                          CcSnackBarHelper.showErrorSnackBar(
                            context: context,
                            message:
                                result.tryGetError()?.message ??
                                el.tr(PrjLocaleKeys.app_error_general),
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
      ),
    );
  }

  Future<Result<Unit, CcFailure>> _delete(BuildContext context) async {
    final repo = getIt<TransactionRepository>();
    final result = await repo.deleteTransaction(transaction.id);

    if (result.isSuccess() && context.mounted) {
      CcSnackBarHelper.showSuccessSnackBar(
        context: context,
        message: el.tr(PrjLocaleKeys.common_delete),
      );
      final refresh = getIt<FinancialRefreshProvider>();
      await refresh.refreshTransactions();
      await refresh.refreshWallets();
      await refresh.refreshReport(showLoading: false);
    }

    return result.map(successMapper: (_) => unit, errorMapper: (e) => e);
  }
}
