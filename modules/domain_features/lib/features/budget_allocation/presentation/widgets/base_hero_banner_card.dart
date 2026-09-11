import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../get_x/budget_allocation_controller.dart';

/// Base reusable widget for Hero Banner cards (Liability, Investment, etc.).
/// Enforces glassmorphic design for back cards and solid priority for front cards.
class BaseHeroBannerCard extends StatelessWidget {
  const BaseHeroBannerCard({
    required this.titleKey,
    required this.balance,
    required this.subtitleKey,
    required this.balanceIcon,
    this.bannerIcon,
    this.bannerIconAsset,
    required this.color,
    required this.isFront,
    this.onTap,
    super.key,
  });

  final String titleKey;
  final int balance;
  final String subtitleKey;
  final IconData balanceIcon;
  final IconData? bannerIcon;
  final String? bannerIconAsset;
  final Color color;
  final bool isFront;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetAllocationController>();
    final walletController = controller.walletController;
    final scheme = context.ccColorScheme;

    return CcBouncing(
      onTap: isFront ? onTap : controller.toggleLiabilityCardStack,
      borderRadius: context.brXl,
      child: Stack(
        children: [
          // Only show glassy background for the card behind to keep front card crisp
          if (!isFront)
            const Positioned.fill(child: CcGlassyGradientBackground()),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
              vertical: context.respPadding(CcPaddingParams.SPACE_LG),
            ),
            decoration: BoxDecoration(
              // Front card is solid "normal debtloan color", back card is transparent
              color: isFront ? color : color.withValues(alpha: 0.1),
              borderRadius: context.brXl,
              border: isFront ? null : context.borderSubtle,
              boxShadow: isFront
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.25),
                        blurRadius: context.respDim(20),
                        offset: Offset(0, context.respDim(10)),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(context, walletController, scheme),
                ),
                const CcSpaceLG(),
                if (isFront) ...[
                  _buildSwapAction(context, controller, scheme),
                  const CcSpaceSM(),
                ],
                _buildBannerIcon(context, scheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    WalletController walletController,
    ColorScheme scheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CcText(
          el.tr(titleKey),
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: scheme.onPrimary.withOpacity(0.85),
          ),
        ),
        const CcSpaceXS(),
        _buildBalanceRow(context, walletController, scheme),
        const CcSpaceXS(),
        CcText(
          el.tr(subtitleKey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: scheme.onPrimary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceRow(
    BuildContext context,
    WalletController walletController,
    ColorScheme scheme,
  ) {
    return Row(
      children: [
        Icon(
          balanceIcon,
          color: scheme.onPrimary.withOpacity(0.8),
          size: context.respIconSize(baseSize: 18),
        ),
        const CcSpaceXS(),
        Obx(
          () => CcText(
            walletController.isBalanceVisible.value
                ? TransactionFormHelpers.formatShort(balance)
                : '*********',
            textStyle: context.ccTextTheme.headlineMedium?.copyWith(
              color: scheme.onPrimary,
              fontWeight: CcTypographyParams.bold,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwapAction(
    BuildContext context,
    BudgetAllocationController controller,
    ColorScheme scheme,
  ) {
    return CcIconButton.bouncing(
      onTap: controller.toggleLiabilityCardStack,
      icon: Icon(
        Icons.swap_vert_rounded,
        color: scheme.onPrimary.withOpacity(0.6),
        size: context.respIconSize(baseSize: 20),
      ),
      width: context.respDim(32),
      height: context.respDim(32),
    );
  }

  Widget _buildBannerIcon(BuildContext context, ColorScheme scheme) {
    return Container(
      padding: EdgeInsets.all(context.respDim(6)),
      decoration: BoxDecoration(
        color: scheme.onPrimary.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: bannerIconAsset != null
          ? Image.asset(
              bannerIconAsset!,
              color: scheme.onPrimary,
              width: context.respIconSize(baseSize: 16),
              height: context.respIconSize(baseSize: 16),
            )
          : CcIconToken(
              bannerIcon ?? Icons.help_outline,
              color: scheme.onPrimary,
              size: 16,
            ),
    );
  }
}
