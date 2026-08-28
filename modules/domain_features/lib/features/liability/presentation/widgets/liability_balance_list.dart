import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/liability_balance_entity.dart';
import 'liability_list_card.dart';

/// Vertical list of [LiabilityListCard]s. Reused both inline in the Liability form's
/// Settle sub-mode (outstanding liabilities only, `shrinkWrap: true` so it nests
/// inside the form's own scroll view) and as the body of [LiabilityListPage] (all
/// liabilities, normal scrolling).
class LiabilityBalanceList extends StatelessWidget {
  final List<LiabilityBalanceEntity> balances;
  final String? selectedLiabilityId;
  final ValueChanged<String>? onLiabilitySelected;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final String emptyMessage;

  const LiabilityBalanceList({
    super.key,
    required this.balances,
    this.selectedLiabilityId,
    this.onLiabilitySelected,
    this.shrinkWrap = true,
    this.physics,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (balances.isEmpty) {
      return CcText(
        emptyMessage,
        align: Alignment.center,
        textAlign: TextAlign.center,
        textStyle: context.ccTextTheme.bodySmall?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant.withAlpha(50),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics:
          physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      itemCount: balances.length,
      separatorBuilder: (context, index) => CcDividerLine(
        color: context.ccColorScheme.outlineVariant.withOpacity(0.2),
      ),
      itemBuilder: (context, index) {
        final balance = balances[index];
        final isSelected = balance.liability.id == selectedLiabilityId;
        return Container(
          color: isSelected
              ? context.ccColorScheme.primary.withAlpha(10)
              : null,
          child: LiabilityListCard(
            balance: balance,
            onTap: onLiabilitySelected != null
                ? () => onLiabilitySelected!(balance.liability.id)
                : null,
          ),
        );
      },
    );
  }
}


