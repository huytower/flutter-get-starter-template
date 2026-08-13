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
    required this.onMore,
    required this.onSeeAll,
    super.key,
  });

  final List<WalletEntity> wallets;
  final VoidCallback onAddInvestment;
  final ValueChanged<WalletEntity> onMore;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.SPACE_MD),
            context.respPadding(CcPaddingParams.SPACE_SM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CcText(
                el.tr(CcLocaleKeys.wallet_investments),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                  color: scheme.onBackground,
                ),
              ),
              Row(
                children: [
                  CcInkWell(
                    onTap: onAddInvestment,
                    child: const CcIconToken(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                    ),
                  ),
                  const CcSpaceSM(),
                  CcInkWell(
                    onTap: onSeeAll,
                    child: CcText(
                      el.tr(CcLocaleKeys.wallet_see_all),
                      textStyle: context.ccTextTheme.titleSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: CcTypographyParams.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        textStyle: context.ccTextTheme.bodyLarge?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant,
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
              onMore: () => onMore(wallet),
              onTap: onSeeAll,
            ),
          );
        },
      ),
    );
  }
}
