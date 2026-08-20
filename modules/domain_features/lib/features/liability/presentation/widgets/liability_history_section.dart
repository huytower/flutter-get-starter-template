import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import '../get_x/liability_detail_controller.dart';
import 'liability_date_row.dart';

/// Repay/collect transaction history list at the bottom of [LiabilityDetailPage].
class LiabilityHistorySection extends StatelessWidget {
  final LiabilityDetailController controller;

  const LiabilityHistorySection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: el.tr(CcLocaleKeys.liability_history_title)),
        const CcSpaceXS(),
        if (controller.history.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.respPadding(CcPaddingParams.SPACE_LG),
            ),
            child: Center(
              child: CcText(
                el.tr(CcLocaleKeys.liability_no_history),
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          for (final txn in controller.history) _LoanHistoryRow(txn: txn),
      ],
    );
  }
}

class _LoanHistoryRow extends StatelessWidget {
  final TransactionEntity txn;

  const _LoanHistoryRow({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isRepay = txn.type == TransactionType.debtRepay;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.respPadding(CcPaddingParams.SPACE_SM),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_SM)),
            decoration: BoxDecoration(
              color: context.ccColorScheme.onSurface.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRepay ? Icons.arrow_upward : Icons.arrow_downward,
              size: context.respIconSize(baseSize: 16),
              color: context.ccColorScheme.onSurfaceVariant,
            ),
          ),
          const CcSpaceMD(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LiabilityDateRow(date: txn.date),
                if (txn.note != null && txn.note!.isNotEmpty)
                  CcText(
                    txn.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textStyle: context.ccTextTheme.labelSmall?.copyWith(
                      color: context.ccColorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          CcText(
            '${TransactionFormHelpers.formatAmount(txn.amount.toString())} đ',
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


