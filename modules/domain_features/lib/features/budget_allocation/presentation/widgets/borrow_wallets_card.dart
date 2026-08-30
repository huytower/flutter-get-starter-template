import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../liability/domain/entities/liability_balance_entity.dart';
import 'liability_wallet_preview_card.dart';

/// Content card for the Borrow (Liability) section on the dashboard.
class BorrowWalletsCard extends StatelessWidget {
  const BorrowWalletsCard({
    required this.balances,
    required this.onSeeAll,
    required this.isFront,
    super.key,
  });

  final List<LiabilityBalanceEntity> balances;
  final VoidCallback onSeeAll;
  final bool isFront;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Stack(
      children: [
        if (!isFront)
          const Positioned.fill(child: CcGlassyGradientBackground()),
        DecoratedBox(
          decoration: BoxDecoration(
            // Front card is opaque surface to hide what's behind
            color: isFront
                ? scheme.surface
                : scheme.surface.withValues(alpha: 0.1),
          ),
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
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: CcText(
        el.tr(CcLocaleKeys.liability_empty_state),
        textStyle: context.ccTextTheme.bodySmall?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant.withAlpha(50),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context) {
    return HorizontalFadeScrollView(
      height: context.respDim(85),
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
