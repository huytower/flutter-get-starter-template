import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/helper/money_format_helper.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/presentation/widgets/edit_transaction_sheet.dart';
import 'report_daily_list_helpers.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final isInflow = computeIsInflow(transaction);
    final amountColor = computeAmountColor(context, transaction);
    final amountText =
        "${isInflow ? '+' : '-'}${formatVnd(transaction.amount)} đ";

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

    return CcInkWell(
      onTap: editable
          ? () => EditTransactionSheet.show(context, transaction)
          : null,
      child: CcSymmetricPadding(
        horizontal: CcPaddingParams.SPACE_MD,
        vertical: CcPaddingParams.SPACE_SM,
        child: Row(
          children: [
            Container(
              width: context.respDim(40),
              height: context.respDim(40),
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: getIcon()),
            ),
            const CcSpaceMD(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CcText(
                    transaction.category,
                    textStyle: context.ccTextTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (transaction.note != null)
                    CcText(
                      transaction.note!,
                      textStyle: context.ccTextTheme.labelSmall,
                      color: context.ccColorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
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
          ],
        ),
      ),
    );
  }
}
