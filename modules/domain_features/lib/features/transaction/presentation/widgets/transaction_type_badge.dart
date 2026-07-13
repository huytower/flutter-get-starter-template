import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/transaction_entity.dart';

class TransactionTypeBadge extends StatelessWidget {
  final String type;

  const TransactionTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isExpense = type == TransactionType.expense;
    final color = isExpense
        ? context.ccColorScheme.errorContainer
        : context.ccColorScheme.primaryContainer;
    final textColor = isExpense
        ? context.ccColorScheme.onErrorContainer
        : context.ccColorScheme.onPrimaryContainer;
    final label = isExpense ? 'EXPENSE' : 'INCOME';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
        vertical: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(context.respDim(8)),
      ),
      child: CcText(
        label,
        textStyle: context.ccTextTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
