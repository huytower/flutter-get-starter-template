import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/presentation/widgets/edit_transaction_sheet.dart';
import '../get_x/report_controller.dart';
import 'delete_transaction_sheet.dart';
import 'quick_edit_transaction_sheet.dart';
import 'report_daily_list_helpers.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    required this.isEditMode,
  });

  final TransactionEntity transaction;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    final isInflow = computeIsInflow(transaction);
    final amountColor = computeAmountColor(context, transaction);
    final amountText =
        "${isInflow ? '+' : '-'}${TransactionFormHelpers.formatShort(transaction.amount)}";

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
        isInflow ? Icons.north_east : Icons.south_west,
        size: context.respIconSize(baseSize: 20),
        color: amountColor,
      );
    }

    final editable = isEditableTransaction(transaction);

    return CcBouncing(
      onTap: editable
          ? () async {
              await EditTransactionSheet.show(context, transaction);
              if (Get.isRegistered<ReportController>()) {
                await Get.find<ReportController>().load(showLoading: false);
              }
            }
          : null,
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
                  CcText(
                    transaction.category,
                    textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (transaction.note != null)
                    CcText(
                      transaction.note!,
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
            if (isEditMode && isEditableTransaction(transaction)) ...[
              const CcSpaceXS(),
              CcIconButton.bouncing(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: context.respIconSize(baseSize: 16),
                  color: context.ccColorScheme.error,
                ),
                onTap: () => DeleteTransactionSheet.show(context, transaction),
              ),
              CcIconButton.bouncing(
                icon: Icon(
                  Icons.edit_rounded,
                  size: context.respIconSize(baseSize: 16),
                  color: context.ccColorScheme.primary,
                ),
                onTap: () async {
                  final isPlainEntry =
                      transaction.type == TransactionType.income ||
                      transaction.type == TransactionType.expense;
                  if (isPlainEntry) {
                    await EditTransactionSheet.show(context, transaction);
                  } else {
                    await QuickEditTransactionSheet.show(context, transaction);
                  }
                  if (Get.isRegistered<ReportController>()) {
                    await Get.find<ReportController>().load(showLoading: false);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
