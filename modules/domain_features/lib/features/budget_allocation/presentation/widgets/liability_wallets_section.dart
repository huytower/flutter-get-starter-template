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

              final Widget activeCard = isLendFront
                  ? LendWalletsCard(balances: lendBalances, onSeeAll: onSeeAll)
                  : BorrowWalletsCard(
                      balances: borrowBalances,
                      onSeeAll: onSeeAll,
                    );

              final double sectionHeight = isBothEmpty ? 35 : 95;

              return SizedBox(
                height: context.respDim(sectionHeight),
                width: double.infinity,
                child: activeCard,
              );
            }),
          ],
        ),
        !showGuidelineBadge
            ? const SizedBox.shrink()
            : Positioned(
                top: 0,
                // Align with Add button
                right: 55,
                child: PrjGuidelineBadge(
                  size: 10,
                  label: guideline.bannerDescription,
                  labelAbove: true,
                  growRight: false,
                ),
              ),
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
}
