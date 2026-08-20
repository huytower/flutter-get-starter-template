import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../guideline/guideline_controller.dart';
import '../../domain/entities/wallet_entity.dart';

/// Individual wallet card item for horizontal strips.
/// Displays icon, name, and balance with glassy selection highlights.
class CcWalletItem extends StatelessWidget {
  final WalletEntity wallet;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int? balance;

  const CcWalletItem({
    super.key,
    required this.wallet,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
    this.onLongPress,
    this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return CcInkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: context.brLg,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isSelected)
            Positioned.fill(
              child: CcGlassyGradientBackground(
                centerColor: activeColor.withValues(alpha: 0.1),
                endColor: activeColor.withValues(alpha: 0.2),
              ),
            ),
          _buildMainCard(context),
          _buildGuidelineBadge(context),
        ],
      ),
    );
  }

  Widget _buildGuidelineBadge(BuildContext context) {
    if (!Get.isRegistered<GuidelineController>()) return const SizedBox();
    final guideline = Get.find<GuidelineController>();

    final isCashWallet = wallet.type == WalletType.cash;
    final isWalletBalanceActive = guideline.isTaskActive('wallet_balance');
    final showing = isCashWallet && isWalletBalanceActive;

    return Positioned(
      top: context.respDim(-6),
      right: context.respDim(-6),
      child: CcGuidelineBadge(
        showing: showing,
        color: guideline.currentColor,
        bounceTrigger: guideline.bounceTrigger,
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.1),
        borderRadius: context.brLg,
        border: Border.all(
          color: activeColor.withValues(alpha: isSelected ? 0.5 : 0.1),
          width: context.respDim(1),
        ),
      ),
      child: CcPadding(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryIcon(context),
            const CcSpaceSM(),
            _buildDesc(context),
          ],
        ),
        6,
        12,
        12,
        6,
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context) {
    return Container(
      width: context.respDim(32),
      height: context.respDim(32),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.12),
        borderRadius: context.brLg,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CcGlassyGradientIcon(
              centerColor: activeColor.withValues(alpha: 0.1),
              endColor: activeColor.withValues(alpha: 0.2),
            ),
          ),
          CcIconToken(
            color: activeColor,
            iconDataFromCode(wallet.iconCode),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildDesc(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CcText(
          wallet.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        CcText(
          balance != null
              ? TransactionFormHelpers.formatShort(balance!)
              : '*****',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: isSelected ? activeColor : scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
