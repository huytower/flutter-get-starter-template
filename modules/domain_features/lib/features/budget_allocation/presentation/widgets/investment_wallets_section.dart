import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../guideline/export_guideline.dart';
import '../../../wallet/export_wallet.dart';
import 'investment_wallet_preview_card.dart';

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
    final guideline = Get.find<GuidelineController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcPadding(
          CcSectionHeader(
            title: el.tr(CcLocaleKeys.wallet_investments),
            icon: Icons.trending_up_outlined,
            actions: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CcBouncing(
                    onTap: onAddInvestment,
                    child: const CcIconToken(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                    ),
                  ),
                  if (showGuidelineBadge)
                    Positioned(
                      right: -4,
                      top: -8,
                      child: PrjGuidelineBadge(
                        size: 6,
                        label: guideline.bannerDescription,
                        labelAbove: true,
                        growRight: false,
                      ),
                    ),
                ],
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
          0, // bottom
          CcPaddingParams.SPACE_LG, // left
          CcPaddingParams.SPACE_MD, // right
          0, // top
        ),
        if (wallets.isEmpty)
          _buildEmptyState(context)
        else
          _buildHorizontalList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CcSectionEmptyState(
      message: el.tr(CcLocaleKeys.wallet_investment_empty),
      verticalPadding: 12,
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
          vertical: context.respDim(4),
        ),
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          return Padding(
            padding: EdgeInsets.only(right: context.respDim(12)),
            child: InvestmentWalletPreviewCard(wallet: wallet, onTap: onSeeAll),
          );
        },
      ),
    );
  }
}
