import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/navigation/domain_router.gr.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/widgets/cc_wallet_strip_card.dart';

/// Section displaying liquid wallet list with add and see all actions.
class LiquidWalletsSection extends StatelessWidget {
  const LiquidWalletsSection({
    required this.wallets,
    required this.onAddWallet,
    required this.onMore,
    this.titleKey = CcLocaleKeys.wallet_your_wallets,
    this.showAddButton = true,
    this.emptyMessageKey,
    super.key,
  });

  final List<WalletEntity> wallets;
  final VoidCallback onAddWallet;
  final ValueChanged<WalletEntity> onMore;
  final String titleKey;
  final bool showAddButton;
  final String? emptyMessageKey;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return CcPadding(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcSectionHeader(
            title: el.tr(titleKey),
            icon: Icons.account_balance_wallet_outlined,
            actions: [
              if (showAddButton)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CcInkWell(
                      onTap: onAddWallet,
                      child: const CcIconToken(
                        Icons.add_circle_outline_rounded,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              if (showAddButton) const CcSpaceSM(),
              if (wallets.isNotEmpty)
                CcTextButton(
                  text: el.tr(CcLocaleKeys.wallet_see_all),
                  onTap: () =>
                      context.router.push(const LiquidWalletListRoute()),
                ),
            ],
          ),
          const CcSpaceXS(),
          CcWalletStripCard(
            wallets: wallets,
            onMore: onMore,
            emptyMessageKey: emptyMessageKey,
          ),
        ],
      ),
      CcPaddingParams.SPACE_SM, // bottom
      CcPaddingParams.SPACE_LG, // left
      CcPaddingParams.SPACE_MD, // right
      CcPaddingParams.SPACE_LG, // top
    );
  }
}
