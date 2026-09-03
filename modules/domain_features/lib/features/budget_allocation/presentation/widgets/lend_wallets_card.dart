import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../liability/domain/entities/liability_balance_entity.dart';
import 'liability_wallet_preview_card.dart';

/// Content card for the Lend (Collect) section on the dashboard.
class LendWalletsCard extends StatelessWidget {
  const LendWalletsCard({
    required this.balances,
    required this.onSeeAll,
    super.key,
  });

  final List<LiabilityBalanceEntity> balances;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final cardHeight = balances.isEmpty ? 35.0 : 95.0;

    return Container(
      width: double.infinity,
      height: context.respDim(cardHeight),
      decoration: BoxDecoration(color: scheme.surface),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (balances.isEmpty)
            _buildEmptyState(context)
          else
            _buildHorizontalList(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CcSectionEmptyState(
      message: el.tr(CcLocaleKeys.liability_empty_state_v2),
      verticalPadding: 0,
      horizontalPadding: CcPaddingParams.SPACE_LG,
    );
  }

  Widget _buildHorizontalList(BuildContext context) {
    return HorizontalFadeScrollView(
      height: context.respDim(95),
      builder: (scrollController) => ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
        ),
        itemCount: balances.length,
        itemBuilder: (context, index) {
          final balance = balances[index];
          return Padding(
            padding: EdgeInsets.only(right: context.respDim(12)),
            child: LiabilityWalletPreviewCard(
              balance: balance,
              onTap: onSeeAll,
            ),
          );
        },
      ),
    );
  }
}
