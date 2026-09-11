import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/navigation/domain_router.gr.dart';
import '../../../guideline/export_guideline.dart';
import '../../../wallet/export_wallet.dart';

/// Section displaying liquid wallet list with add and see all actions.
class LiquidWalletsSection extends StatelessWidget {
  const LiquidWalletsSection({
    required this.wallets,
    required this.onAddWallet,
    this.titleKey = CcLocaleKeys.wallet_your_wallets,
    this.showAddButton = true,
    this.emptyMessageKey,
    this.showGuidelineBadge = false,
    this.badgeColor,
    super.key,
  });

  final List<WalletEntity> wallets;
  final VoidCallback onAddWallet;
  final String titleKey;
  final bool showAddButton;
  final String? emptyMessageKey;
  final bool showGuidelineBadge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final guideline = Get.find<GuidelineController>();

    return CcPadding(
      Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CcSectionHeader(
                title: el.tr(titleKey),
                icon: Icons.account_balance_wallet_outlined,
                actions: [
                  if (showAddButton)
                    CcBouncing(
                      onTap: onAddWallet,
                      child: const CcIconToken(
                        Icons.add_circle_outline_rounded,
                        size: 20,
                      ),
                    ),
                  if (showAddButton) const CcSpaceSM(),
                  CcTextButton(
                    text: el.tr(CcLocaleKeys.wallet_see_all),
                    onTap: () =>
                        context.router.push(const LiquidWalletListRoute()),
                  ),
                ],
              ),
              const CcSpaceSM(),
              WalletStripCard(
                wallets: wallets,
                emptyMessageKey: emptyMessageKey,
              ),
            ],
          ),
          if (showGuidelineBadge)
            Positioned(
              right: 0,
              top: 0,
              child: PrjGuidelineBadge(
                size: context.respDim(6),
                label: guideline.bannerDescription,
                labelAbove: false,
                growRight: false,
              ),
            ),
        ],
      ),
      0, // bottom
      CcPaddingParams.SPACE_LG, // left
      CcPaddingParams.SPACE_MD, // right
      0, // top
    );
  }
}
