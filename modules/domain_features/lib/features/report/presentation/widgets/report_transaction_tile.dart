import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/budget/budget_name_helper.dart';
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/features/category/data/datasources/local/category_seed.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/presentation/helper/transaction_form_helpers.dart';
import 'delete_transaction_sheet.dart';
import 'quick_edit_transaction_sheet.dart';
import 'report_daily_list_helpers.dart';
import 'report_source_chip.dart';

class ReportTransactionTile extends StatelessWidget {
  const ReportTransactionTile({
    required this.transaction,
    required this.hasEditMode,
    this.reconciledUntil,
    this.sourceName,
  });

  final TransactionEntity transaction;
  final bool hasEditMode;

  /// Name shown in a chip beside the title (the investment position of an
  /// investment entry). Null hides the chip.
  final String? sourceName;

  /// Latest reconciliation; a transaction dated at or before it shows a lock
  /// instead of edit/delete.
  final DateTime? reconciledUntil;

  @override
  Widget build(BuildContext context) {
    final hasInflow = computeIsInflow(transaction);
    final amountColor = computeAmountColor(context, transaction);
    final amountText =
        "${hasInflow ? '+' : '-'}${TransactionFormHelpers.formatShortWithSymbol(transaction.amount, currencyCode: transaction.currencyCode)}";

    Widget getIcon() {
      if (transaction.categoryIconCode != null) {
        return Icon(
          iconDataFromCode(
            transaction.categoryIconCode!,
            fontFamily: transaction.categoryIconFamily,
          ),
          size: context.respIconSize(baseSize: 20),
          color: amountColor,
        );
      }
      return Icon(
        hasInflow ? Icons.north_east : Icons.south_west,
        size: context.respIconSize(baseSize: 20),
        color: amountColor,
      );
    }

    return CcBouncing(
      onTap: null,
      child: CcSymmetricPadding(
        horizontal: CcPaddingParams.SPACE_SM,
        vertical: CcPaddingParams.SPACE_SM,
        child: Row(
          children: [
            Container(
              width: context.respDim(30),
              height: context.respDim(30),
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: getIcon()),
            ),
            const CcSpaceSM(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A long chip moves below the title instead of squeezing it.
                  Wrap(
                    spacing: context.respDim(CcPaddingParams.SPACE_XS),
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      IntrinsicWidth(
                        child: CcText(
                          BudgetNameHelper.getDisplayName(
                            name: transaction.category,
                            categoryNameKey: CategorySeed.categories
                                .firstWhereOrNull(
                                  (c) => c.id == transaction.categoryId,
                                )
                                ?.nameKey,
                          ),
                          textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (sourceName != null)
                        ReportSourceChip(
                          label: sourceName!,
                          color: amountColor,
                        ),
                    ],
                  ),
                  if (transaction.note != null)
                    CcText(
                      transaction.note!,
                      maxLines: 2,
                      textStyle: context.ccTextTheme.bodySmall,
                      color: context.ccColorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                CcText(
                  amountText,
                  textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
                CcText(
                  el.DateFormat('dd/MM').format(transaction.date),
                  textStyle: context.ccTextTheme.labelSmall?.copyWith(
                    color: context.ccColorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (hasEditMode &&
                hasEditableTransaction(transaction) &&
                !hasEditableTransaction(
                  transaction,
                  reconciledUntil: reconciledUntil,
                )) ...[
              // Reconciled: closed for edits; a tap explains how to correct it.
              const CcSpaceXS(),
              CcIconButton.bouncing(
                icon: Icon(
                  Icons.lock_outline_rounded,
                  size: context.respIconSize(baseSize: 16),
                  color: context.ccColorScheme.onSurfaceVariant,
                ),
                onTap: () => CcSnackBarHelper.showSnackBar(
                  context: context,
                  message: el.tr(
                    PrjLocaleKeys.transaction_validation_reconciled,
                  ),
                ),
              ),
            ] else if (hasEditMode &&
                hasEditableTransaction(
                  transaction,
                  reconciledUntil: reconciledUntil,
                )) ...[
              const CcSpaceXS(),
              CcIconButton.bouncing(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: context.respIconSize(baseSize: 16),
                  color: context.ccColorScheme.error,
                ),
                onTap: () => DeleteTransactionSheet.confirmAndDelete(
                  context,
                  transaction,
                ),
              ),
              CcIconButton.bouncing(
                icon: Icon(
                  Icons.edit_rounded,
                  size: context.respIconSize(baseSize: 16),
                  color: context.ccColorScheme.primary,
                ),
                onTap: () async {
                  await QuickEditTransactionSheet.show(context, transaction);
                  final refresh = getIt<FinancialRefreshProvider>();
                  await refresh.refreshWallets();
                  await refresh.refreshReport(showLoading: false);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
