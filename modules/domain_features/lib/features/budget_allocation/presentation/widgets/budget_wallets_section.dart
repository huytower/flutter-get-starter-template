import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/navigation/domain_router.gr.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/widgets/cc_wallet_strip_card.dart';

/// Section displaying wallet list with add and see all actions.
class BudgetWalletsSection extends StatelessWidget {
  const BudgetWalletsSection({
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
    final guideline = Get.find<GuidelineController>();

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
                el.tr(titleKey),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                  color: scheme.onBackground,
                ),
              ),
              Row(
                children: [
                  if (showAddButton)
                    Obx(
                      () => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CcInkWell(
                            onTap: onAddWallet,
                            child: const CcIconToken(
                              Icons.add_circle_outline_rounded,
                              size: 20,
                            ),
                          ),
                          if (guideline.isTaskActive('wallet_balance'))
                            Positioned(
                              top: -10,
                              right: -10,
                              child: CcGuidelineBadge(
                                size: 6,
                                color: guideline.currentColor,
                                bounceTrigger: guideline.bounceTrigger,
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (showAddButton) const CcSpaceSM(),
                  if (wallets.isNotEmpty)
                    CcInkWell(
                      onTap: () =>
                          context.router.push(const LiquidWalletListRoute()),
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
        CcWalletStripCard(
          wallets: wallets,
          onMore: onMore,
          emptyMessageKey: emptyMessageKey,
        ),
      ],
    );
  }
}
