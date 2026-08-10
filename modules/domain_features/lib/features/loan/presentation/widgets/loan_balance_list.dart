import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/loan_balance_entity.dart';
import 'loan_list_card.dart';

/// Vertical list of [LoanListCard]s. Reused both inline in the Loan form's
/// Settle sub-mode (outstanding loans only, `shrinkWrap: true` so it nests
/// inside the form's own scroll view) and as the body of [LoanListPage] (all
/// loans, normal scrolling).
class LoanBalanceList extends StatelessWidget {
  final List<LoanBalanceEntity> balances;
  final String? selectedLoanId;
  final ValueChanged<String>? onLoanSelected;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final String emptyMessage;

  const LoanBalanceList({
    super.key,
    required this.balances,
    this.selectedLoanId,
    this.onLoanSelected,
    this.shrinkWrap = true,
    this.physics,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (balances.isEmpty) {
      return NoDataResponseWidget(message: emptyMessage);
    }
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics:
          physics ??
          (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      itemCount: balances.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: context.ccColorScheme.outlineVariant.withOpacity(0.2),
      ),
      itemBuilder: (context, index) {
        final balance = balances[index];
        final isSelected = balance.loan.id == selectedLoanId;
        return Container(
          color: isSelected
              ? context.ccColorScheme.primary.withAlpha(10)
              : null,
          child: LoanListCard(
            balance: balance,
            onTap: onLoanSelected != null
                ? () => onLoanSelected!(balance.loan.id)
                : null,
          ),
        );
      },
    );
  }
}
