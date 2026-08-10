import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../transaction/presentation/widgets/cc_form_label.dart';
import '../../domain/entities/loan_entity.dart';
import 'loan_date_row.dart';

/// Repayment schedule for [LoanDetailPage]: per-installment due dates for
/// installment loans, or the single final due date otherwise.
class LoanScheduleInfo extends StatelessWidget {
  final LoanEntity current;
  final Color accentColor;

  const LoanScheduleInfo({
    super.key,
    required this.current,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (current.isInstallment) {
      final installments = current.installments ?? const [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcFormLabel(text: el.tr(CcLocaleKeys.transaction_loan_schedule_label)),
          const CcSpaceXS(),
          for (final period in installments)
            Padding(
              padding: EdgeInsets.only(
                bottom: context.respPadding(CcPaddingParams.SPACE_XS),
              ),
              child: Row(
                children: [
                  LoanDateRow(
                    date: period.dueDate,
                    icon: Icons.calendar_today_outlined,
                    iconColor: accentColor,
                  ),
                  const Spacer(),
                  CcText(
                    '${TransactionFormHelpers.formatAmount(period.amount.toString())} đ',
                    textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    final dueDate = current.finalDueDate;
    if (dueDate == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(
          text: el.tr(CcLocaleKeys.transaction_loan_final_due_date_label),
        ),
        const CcSpaceXS(),
        LoanDateRow(
          date: dueDate,
          icon: Icons.event_outlined,
          iconSize: 18,
          iconColor: accentColor,
        ),
      ],
    );
  }
}
