import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../get_x/budget_allocation_controller.dart';
import 'borrow_hero_card.dart';
import 'lend_hero_card.dart';

/// Hero banner for liabilities that uses the Front/Back Card stack mechanism.
/// prioritized by frequency: Borrow (Front) and Lend (Back).
class LiabilityHeroBanner extends StatelessWidget {
  const LiabilityHeroBanner({
    required this.walletController,
    required this.borrowBalance,
    required this.lendBalance,
    required this.totalBalance,
    this.onTap,
    super.key,
  });

  final WalletController walletController;
  final RxInt borrowBalance;
  final RxInt lendBalance;
  final RxInt totalBalance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetAllocationController>();

    return Obx(() {
      final isLendFront = controller.isLendSectionFront.value;

      return Container(
        padding: EdgeInsets.only(
          top: context.respPadding(CcPaddingParams.SPACE_SM),
          bottom: context.respPadding(CcPaddingParams.SPACE_XS),
        ),
        // The stack needs a height that accommodates the card height plus the
        // offset of the back card.
        height: context.respDim(125),
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Back Card
            _buildAnimatedCard(
              context: context,
              isFront: false,
              child: isLendFront
                  ? BorrowHeroCard(
                      walletController: walletController,
                      balance: borrowBalance.value,
                      isFront: false,
                      onTap: onTap,
                    )
                  : LendHeroCard(
                      walletController: walletController,
                      balance: lendBalance.value,
                      isFront: false,
                      onTap: onTap,
                    ),
            ),
            // Front Card
            _buildAnimatedCard(
              context: context,
              isFront: true,
              child: isLendFront
                  ? LendHeroCard(
                      walletController: walletController,
                      balance: lendBalance.value,
                      isFront: true,
                      onTap: onTap,
                    )
                  : BorrowHeroCard(
                      walletController: walletController,
                      balance: borrowBalance.value,
                      isFront: true,
                      onTap: onTap,
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAnimatedCard({
    required BuildContext context,
    required bool isFront,
    required Widget child,
  }) {
    // Premium animation values matching TransactionTabBar pattern
    final double scale = isFront ? 1.0 : 0.94;
    final double opacity = isFront ? 1.0 : 0.45;
    final double yOffset = isFront ? 0 : -context.respDim(10);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: const Cubic(0.2, 0.8, 0.2, 1.0),
      top: yOffset,
      left: context.respPadding(CcPaddingParams.SPACE_LG),
      right: context.respPadding(CcPaddingParams.SPACE_LG),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 400),
        curve: const Cubic(0.2, 0.8, 0.2, 1.0),
        scale: scale,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          curve: const Cubic(0.2, 0.8, 0.2, 1.0),
          opacity: opacity,
          child: child,
        ),
      ),
    );
  }
}
