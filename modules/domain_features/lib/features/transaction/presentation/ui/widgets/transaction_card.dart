import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return CcInkWell(
      onTap: () => getIt<TransactionCoordinator>()
          .navigateToTransactionDetail(context, transaction),
      borderRadius: CcWidgetHelper.getBorderRoundedLG(),
      child: Container(
        height: context.respDim(140),
        margin: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_XS),
          vertical: context.respPadding(CcPaddingParams.SPACE_SM),
        ),
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
        decoration: BoxDecoration(
          color: context.ccColorScheme.surface,
          borderRadius: CcWidgetHelper.getBorderRoundedLG(),
          boxShadow: CcWidgetHelper.getBoxShadows(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CcText(
                  transaction.category,
                  textStyle: context.ccTextTheme.titleMedium?.copyWith(
                    fontWeight: CcTypographyParams.bold,
                    color: context.ccColorScheme.primary,
                    fontSize: context.respFontSize(CcTypographyParams.titleMedium),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
                    vertical: context.respPadding(CcPaddingParams.SPACE_XS),
                  ),
                  decoration: BoxDecoration(
                    color: transaction.type == 'expense'
                        ? context.ccColorScheme.errorContainer
                        : context.ccColorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(context.respDim(8)),
                  ),
                  child: CcText(
                    transaction.type == 'expense' ? 'EXPENSE' : 'INCOME',
                    textStyle: context.ccTextTheme.labelSmall?.copyWith(
                      color: transaction.type == 'expense'
                          ? context.ccColorScheme.onErrorContainer
                          : context.ccColorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const CcSpaceXS(),
            CcText(
              '${transaction.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")} đ',
              textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: transaction.type == 'expense'
                    ? context.ccColorScheme.error
                    : context.ccColorScheme.primary,
              ),
            ),
            const Spacer(),
            CcText(
              transaction.note ?? '',
              textStyle: context.ccTextTheme.bodySmall?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
