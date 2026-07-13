import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/money_format.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_card_container.dart';
import 'transaction_type_badge.dart';

class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return TransactionCardContainer(
      onTap: () => getIt<TransactionCoordinator>()
          .navigateToTransactionDetail(context, transaction),
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
              TransactionTypeBadge(type: transaction.type),
            ],
          ),
          const CcSpaceXS(),
          CcText(
            '${formatVnd(transaction.amount)} đ',
            textStyle: context.ccTextTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: transaction.type == TransactionType.expense
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
    );
  }
}
