import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/navigation/domain_router.gr.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import 'wallet_strip_card.dart';

/// Section displaying wallet list with add and see all actions.
class BudgetWalletsSection extends StatelessWidget {
  const BudgetWalletsSection({
    required this.wallets,
    required this.onAddWallet,
    required this.onMore,
    super.key,
  });

  final List<WalletEntity> wallets;
  final VoidCallback onAddWallet;
  final ValueChanged<WalletEntity> onMore;

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
                el.tr(CcLocaleKeys.wallet_your_wallets),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                  color: scheme.onBackground,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onAddWallet,
                    child: const CcIconToken(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                    ),
                  ),
                  const CcSpaceSM(),
                  GestureDetector(
                    onTap: () => context.router.push(const WalletListRoute()),
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
        WalletStripCard(wallets: wallets, onMore: onMore),
      ],
    );
  }
}
