import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/features/budget_allocation/presentation/widgets/investment_wallet_preview_card.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../wallet/domain/entities/wallet_entity.dart';

/// Section displaying investment wallets in a grid layout, following the
/// Budget Allocation design pattern.
class InvestmentWalletsSection extends StatelessWidget {
  const InvestmentWalletsSection({
    required this.wallets,
    required this.onAddInvestment,
    required this.onSeeAll,
    this.showGuidelineBadge = false,
    this.badgeColor,
    super.key,
  });

  final List<WalletEntity> wallets;
  final VoidCallback onAddInvestment;
  final VoidCallback onSeeAll;
  final bool showGuidelineBadge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final dotColor = badgeColor ?? scheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcPadding(
          CcSectionHeader(
            title: el.tr(CcLocaleKeys.wallet_investments),
            icon: Icons.trending_up_outlined,
            actions: [
              CcBouncing(
                onTap: onAddInvestment,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CcIconToken(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                    ),
                    if (showGuidelineBadge)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: CcGuidelineBadge(
                          size: 6,
                          color: dotColor,
                        ),
                      ),
                  ],
                ),
              ),
              if (wallets.isNotEmpty) ...[
                const CcSpaceSM(),
                CcTextButton(
                  text: el.tr(CcLocaleKeys.wallet_see_all),
                  onTap: onSeeAll,
                ),
              ],
            ],
          ),
          CcPaddingParams.SPACE_SM, // bottom
          CcPaddingParams.SPACE_LG, // left
          CcPaddingParams.SPACE_MD, // right
          CcPaddingParams.SPACE_LG, // top
        ),
        if (wallets.isEmpty)
          _buildEmptyState(context)
        else
          _buildHorizontalList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.SPACE_LG,
      vertical: 12,
      child: CcText(
        el.tr(CcLocaleKeys.wallet_investment_empty),
        textAlign: TextAlign.center,
        textStyle: context.ccTextTheme.bodySmall?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant.withAlpha(50),
        ),
      ),
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
          vertical: context.respDim(4),
        ),
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          return Padding(
            padding: EdgeInsets.only(right: context.respDim(12)),
            child: InvestmentWalletPreviewCard(
              wallet: wallet,
              onTap: onSeeAll,
            ),
          );
        },
      ),
    );
  }
}
