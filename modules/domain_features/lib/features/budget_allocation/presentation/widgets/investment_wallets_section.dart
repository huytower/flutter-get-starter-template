import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/money_format_helper.dart';
import '../../../../core/helper/wallet_icon_helper.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';

/// Section displaying investment wallets in a grid layout, following the
/// Budget Allocation design pattern.
class InvestmentWalletsSection extends StatelessWidget {
  const InvestmentWalletsSection({
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
                el.tr(CcLocaleKeys.wallet_investments),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                  color: scheme.onBackground,
                ),
              ),
              Row(
                children: [
                  CcInkWell(
                    onTap: onAddWallet,
                    child: const CcIconToken(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                    ),
                  ),
                  const CcSpaceSM(),
                  CcInkWell(
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
        if (wallets.isEmpty) _buildEmptyState(context) else _buildGrid(context),
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

  Widget _buildGrid(BuildContext context) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.SPACE_LG,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: context.respDim(100),
          crossAxisSpacing: context.respDim(CcPaddingParams.PAGE_XS),
          mainAxisSpacing: context.respDim(CcPaddingParams.PAGE_XS),
        ),
        itemCount: wallets.length,
        itemBuilder: (context, i) => _InvestmentWalletCard(
          wallet: wallets[i],
          onMore: () => onMore(wallets[i]),
        ),
      ),
    );
  }
}

class _InvestmentWalletCard extends StatelessWidget {
  final WalletEntity wallet;
  final VoidCallback onMore;

  const _InvestmentWalletCard({required this.wallet, required this.onMore});

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final controller = Get.find<WalletController>();

    return CcInkWell(
      onTap: () => context.router.push(const WalletListRoute()),
      onLongPress: onMore,
      borderRadius: context.brLg,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CcGlassyGradientBackground()),
          Container(
            padding: EdgeInsets.all(context.respDim(12)),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: context.brLg,
              border: Border.all(
                color: scheme.onSurface.withOpacity(0.08),
                width: context.respDim(1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: context.respDim(32),
                      height: context.respDim(32),
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.12),
                        borderRadius: context.brLg,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Positioned.fill(child: CcGlassyGradientIcon()),
                          CcIconToken(
                            iconDataFromCode(wallet.iconCode),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    const CcSpaceSM(),
                    Expanded(
                      child: CcText(
                        wallet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textStyle: context.ccTextTheme.labelMedium?.copyWith(
                          fontWeight: CcTypographyParams.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const CcSpaceSM(),
                Divider(
                  color: scheme.onSurface.withOpacity(0.06),
                  height: context.respDim(1),
                ),
                const CcSpaceSM(),
                Obx(
                  () => CcText(
                    controller.isBalanceVisible.value
                        ? formatVndWithSymbol(
                            controller.bookBalanceOf(wallet.id),
                          )
                        : '*****',
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant.withOpacity(0.8),
                      fontWeight: CcTypographyParams.semiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
