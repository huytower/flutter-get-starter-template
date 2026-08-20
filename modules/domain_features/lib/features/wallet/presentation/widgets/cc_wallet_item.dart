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
    return CcInteractBtnWrapper(
      onTap: onTap,
      useDebounce: true,
      isBouncing: true,
      isEnable: true,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (isSelected)
              Positioned.fill(
                child: CcGlassyGradientBackground(
                  centerColor: activeColor.withAlpha(10),
                  endColor: activeColor.withAlpha(20),
                ),
              ),
            _buildMainCard(context),
            _buildGuidelineBadge(context),
          ],
        ),
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
    final scheme = context.ccColorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? activeColor.withAlpha(5)
            : scheme.onSurface.withAlpha(5),
        borderRadius: context.brLg,
        border: Border.all(
          color: isSelected
              ? activeColor.withAlpha(10)
              : scheme.onSurface.withAlpha(5),
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
        4,
        6,
        16,
        4,
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(35),
      height: context.respDim(35),
      decoration: BoxDecoration(
        color: isSelected
            ? activeColor.withAlpha(10)
            : scheme.onSurface.withAlpha(5),
        borderRadius: context.brMd,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected)
            Positioned.fill(
              child: CcGlassyGradientIcon(
                centerColor: activeColor.withAlpha(20),
                endColor: activeColor.withAlpha(40),
              ),
            ),
          CcIconToken(
            color: isSelected ? activeColor : scheme.onSurfaceVariant,
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
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        CcText(
          balance != null
              ? TransactionFormHelpers.formatShort(balance!)
              : '*****',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: isSelected ? activeColor : scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
