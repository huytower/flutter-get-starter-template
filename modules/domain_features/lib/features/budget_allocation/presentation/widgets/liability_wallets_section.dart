import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../liability/domain/entities/liability_balance_entity.dart';
import '../get_x/budget_allocation_controller.dart';
import 'borrow_wallets_card.dart';
import 'lend_wallets_card.dart';

/// A "Card-stack Reveal" section for liabilities and lending.
/// Decoupled into BorrowWalletsCard and LendWalletsCard for cleaner logic.
class LiabilityWalletsSection extends StatelessWidget {
  const LiabilityWalletsSection({
    required this.borrowBalances,
    required this.lendBalances,
    required this.onAddLoan,
    required this.onSeeAll,
    this.showGuidelineBadge = false,
    this.badgeColor,
    super.key,
  });

  final List<LiabilityBalanceEntity> borrowBalances;
  final List<LiabilityBalanceEntity> lendBalances;
  final VoidCallback onAddLoan;
  final VoidCallback onSeeAll;
  final bool showGuidelineBadge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetAllocationController>();

    return Obx(() {
      final isLendFront = controller.isLendSectionFront.value;

      return Container(
        margin: EdgeInsets.symmetric(
          vertical: context.respPadding(CcPaddingParams.SPACE_SM),
        ),
        // Height needs to fit the card content + the stack offset
        height: context.respDim(160),
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Back Card (Handles tap to swap)
            _buildAnimatedCard(
              context: context,
              isFront: false,
              onToggle: controller.toggleLiabilityCardStack,
              child: isLendFront
                  ? BorrowWalletsCard(
                      balances: borrowBalances,
                      onAdd: onAddLoan,
                      onSeeAll: onSeeAll,
                      isFront: false,
                    )
                  : LendWalletsCard(
                      balances: lendBalances,
                      onAdd: onAddLoan,
                      onSeeAll: onSeeAll,
                      isFront: false,
                    ),
            ),
            // Front Card
            _buildAnimatedCard(
              context: context,
              isFront: true,
              onToggle: controller.toggleLiabilityCardStack,
              child: isLendFront
                  ? LendWalletsCard(
                      balances: lendBalances,
                      onAdd: onAddLoan,
                      onSeeAll: onSeeAll,
                      isFront: true,
                    )
                  : BorrowWalletsCard(
                      balances: borrowBalances,
                      onAdd: onAddLoan,
                      onSeeAll: onSeeAll,
                      isFront: true,
                      showGuidelineBadge: showGuidelineBadge,
                      badgeColor: badgeColor,
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
    required VoidCallback onToggle,
  }) {
    // Premium animation values matching TransactionTabBar
    final double scale = isFront ? 1.0 : 0.94;
    final double opacity = isFront ? 1.0 : 0.45;
    final double yOffset = isFront ? 0 : -context.respDim(12);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: const Cubic(0.2, 0.8, 0.2, 1.0),
      top: yOffset,
      left: 0,
      right: 0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 400),
        curve: const Cubic(0.2, 0.8, 0.2, 1.0),
        scale: scale,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          curve: const Cubic(0.2, 0.8, 0.2, 1.0),
          opacity: opacity,
          child: IgnorePointer(
            ignoring: !isFront,
            child: GestureDetector(
              onTap: isFront ? null : onToggle,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
