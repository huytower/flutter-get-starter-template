import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../guideline/export_guideline.dart';
import '../../../liability/export_liability.dart';
import '../get_x/budget_allocation_controller.dart';
import 'borrow_wallets_card.dart';
import 'lend_wallets_card.dart';

/// A section for liabilities and lending that follows the InvestmentWalletsSection
/// design pattern but uses a Card-stack mechanism for its content.
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
    final guideline = Get.find<GuidelineController>();

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeaderSection(controller, context),
            const CcSpaceSM(),
            Obx(() {
              final isLendFront = controller.isLendSectionFront.value;
              final isBothEmpty =
                  borrowBalances.isEmpty && lendBalances.isEmpty;

              final borrowCard = BorrowWalletsCard(
                balances: borrowBalances,
                onSeeAll: onSeeAll,
                isFront: !isLendFront,
              );

              final lendCard = LendWalletsCard(
                balances: lendBalances,
                onSeeAll: onSeeAll,
                isFront: isLendFront,
              );

              final double sectionHeight = isBothEmpty ? 35 : 115;
              final double topPadding = isBothEmpty ? 0 : 12;

              return Container(
                height: context.respDim(sectionHeight),
                padding: EdgeInsets.only(top: context.respDim(topPadding)),
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    if (!isBothEmpty) ...[
                      // Back Card
                      _buildAnimatedCard(
                        context: context,
                        isFront: false,
                        onToggle: controller.toggleLiabilityCardStack,
                        child: isLendFront ? borrowCard : lendCard,
                      ),
                    ],
                    // Front Card
                    _buildAnimatedCard(
                      context: context,
                      isFront: true,
                      onToggle: controller.toggleLiabilityCardStack,
                      child: isLendFront ? lendCard : borrowCard,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
        Obx(() {
          if (!showGuidelineBadge) return const SizedBox.shrink();
          return Positioned(
            top: 0,
            // Align with Add button: SeeAll (~60) + SpaceSM (8) = 68
            right: 55,
            child: PrjGuidelineBadge(
              size: 6,
              label: guideline.bannerDescription,
              labelAbove: false,
              growRight: false,
            ),
          );
        }),
      ],
    );
  }

  CcPadding buildHeaderSection(
    BudgetAllocationController controller,
    BuildContext context,
  ) {
    return CcPadding(
      CcSectionHeader(
        title: el.tr(CcLocaleKeys.liability_list_title),
        icon: Icons.warning_amber_outlined,
        actions: [
          CcBouncing(
            onTap: onAddLoan,
            child: const CcIconToken(
              Icons.add_circle_outline_rounded,
              size: 20,
            ),
          ),
          const CcSpaceSM(),
          CcTextButton(
            text: el.tr(CcLocaleKeys.wallet_see_all),
            onTap: onSeeAll,
          ),
        ],
      ),
      0, // bottom
      CcPaddingParams.SPACE_LG, // left
      CcPaddingParams.SPACE_MD, // right
      0, // top
    );
  }

  Widget _buildAnimatedCard({
    required BuildContext context,
    required bool isFront,
    required Widget child,
    required VoidCallback onToggle,
  }) {
    // Premium animation values matching TransactionTabBar
    final double scale = isFront ? 1.0 : 0.94;
    final double opacity = isFront ? 1.0 : 0.9;
    // final double opacity = isFront ? 1.0 : 0.45;
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
