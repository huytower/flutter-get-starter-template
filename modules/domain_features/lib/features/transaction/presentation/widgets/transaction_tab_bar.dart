import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../guideline/export_guideline.dart';
import '../get_x/transaction_controller.dart';

extension TransactionTabKindStyle on TransactionTabKind {
  String label(BuildContext context) => switch (this) {
    TransactionTabKind.expense => el.tr(CcLocaleKeys.transaction_expense_slip),
    TransactionTabKind.income => el.tr(CcLocaleKeys.transaction_income_slip),
    TransactionTabKind.investment => el.tr(CcLocaleKeys.transaction_investment),
    TransactionTabKind.liability => el.tr(CcLocaleKeys.liability_title),
    TransactionTabKind.lend => el.tr(CcLocaleKeys.liability_lend),
  };

  Color color(BuildContext context) => switch (this) {
    TransactionTabKind.expense => context.ccColorScheme.error,
    TransactionTabKind.income => PrjColors.success,
    TransactionTabKind.investment => context.ccColorScheme.investment,
    TransactionTabKind.liability => context.ccColorScheme.debtLoan,
    TransactionTabKind.lend => context.ccColorScheme.debtLoanSecondary,
  };
}

/// A "Card-stack Reveal" tab bar implementing Progressive Disclosure.
///
/// High-frequency tabs (Expense, Income) are on the primary card, while
/// low-frequency/locked tabs (Investment, Debt/Loan) are on a secondary card
/// stacked behind. Tapping the card edges swaps their depth with a slide
/// animation.
class TransactionTabBar extends StatelessWidget {
  const TransactionTabBar({
    super.key,
    required this.controller,
    required this.tabController,
    this.showInvestmentBadge = false,
    this.showLiabilityBadge = false,
    this.showLendBadge = false,
  });

  final TransactionController controller;
  final TabController tabController;
  final bool showInvestmentBadge;
  final bool showLiabilityBadge;
  final bool showLendBadge;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Obx(() {
      final isSecondaryFront = controller.isSecondaryCardFront.value;

      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: context.respDim(64),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Back Card (Affordance)
                  _buildCard(
                    context: context,
                    isFront: false,
                    isSecondary: !isSecondaryFront,
                    scheme: scheme,
                  ),
                  // Front Card (Interaction)
                  _buildCard(
                    context: context,
                    isFront: true,
                    isSecondary: isSecondaryFront,
                    scheme: scheme,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCard({
    required BuildContext context,
    required bool isFront,
    required bool isSecondary,
    required ColorScheme scheme,
  }) {
    final cardHeight = context.respDim(44);
    final cardWidth =
        MediaQuery.of(context).size.width -
        (context.respPadding(CcPaddingParams.PAGE_MD) * 2);

    final tabs = isSecondary
        ? [
            TransactionTabKind.investment,
            TransactionTabKind.liability,
            TransactionTabKind.lend,
          ]
        : [TransactionTabKind.expense, TransactionTabKind.income];

    // Animation values
    final double scale = isFront ? 1.0 : 0.94;
    final double opacity = isFront ? 1.0 : 0.45;
    final double yOffset = isFront ? 0 : -context.respDim(8);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: const Cubic(0.2, 0.8, 0.2, 1.0),
      top: yOffset,
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
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: isFront
                    ? null
                    : () {
                        controller.toggleCardStack();
                        tabController.animateTo(
                          controller.selectedTabIndex.value,
                        );
                      },
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: context.brLg,
                    boxShadow: [
                      BoxShadow(
                        color: scheme.onSurface.withOpacity(
                          isFront ? 0.12 : 0.05,
                        ),
                        blurRadius: context.respDim(12),
                        offset: Offset(0, context.respDim(isFront ? 6 : 2)),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(context.respDim(4)),
                  child: _buildActualTabBar(context, tabs, scheme),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActualTabBar(
    BuildContext context,
    List<TransactionTabKind> tabs,
    ColorScheme scheme,
  ) {
    final selectedIndex = controller.selectedTabIndex.value;
    final currentKind = controller
        .visibleTabs[selectedIndex.clamp(0, controller.visibleTabs.length - 1)];

    return Row(
      children: [
        for (final tab in tabs)
          Expanded(
            child: _buildTabItem(context, tab, currentKind == tab, scheme),
          ),
        // Reveal/Back toggle chip at the end of the front card
        _buildToggleAction(context, scheme),
      ],
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    TransactionTabKind kind,
    bool isSelected,
    ColorScheme scheme,
  ) {
    final isUnlocked = controller.isTabUnlocked(kind);
    final activeColor = kind.color(context);

    return CcInteractBtnWrapper(
      isEnable: true,
      isBouncing: true,
      useDebounce: true,
      onTap: () {
        final index = controller.visibleTabs.indexOf(kind);
        controller.setTabIndex(index);
        tabController.animateTo(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: context.brLg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: context.respIconSize(baseSize: 12),
                  color: isSelected
                      ? activeColor.withOpacity(0.6)
                      : scheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            CcText(
              kind.label(context),
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? CcTypographyParams.bold : null,
                color: isSelected
                    ? activeColor
                    : scheme.onSurfaceVariant.withOpacity(
                        isUnlocked ? 1.0 : 0.5,
                      ),
              ),
            ),
            if (kind == TransactionTabKind.investment &&
                showInvestmentBadge &&
                !isSelected)
              _buildBadge(context),
            if (kind == TransactionTabKind.liability &&
                showLiabilityBadge &&
                !isSelected)
              _buildBadge(context),
            if (kind == TransactionTabKind.lend && showLendBadge && !isSelected)
              _buildBadge(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context) {
    final guideline = Get.find<GuidelineController>();
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: PrjGuidelineBadge(size: 6, label: null),
    );
  }

  Widget _buildToggleAction(BuildContext context, ColorScheme scheme) {
    final guideline = Get.find<GuidelineController>();
    final bool isSecondaryFront = controller.isSecondaryCardFront.value;
    final String? activeTaskId = guideline.currentTaskId;

    // Show badge on reveal icon if there's a task on the back card
    final bool hasBackCardTask =
        activeTaskId == 'investment' ||
        activeTaskId == 'liability' ||
        activeTaskId == 'lend';

    // Show label on the reveal icon ONLY when the back card is NOT in front
    // but the dot stays if there's an active task.
    final bool showLabelOnReveal = !isSecondaryFront && hasBackCardTask;
    final bool showBadgeOnReveal = !isSecondaryFront && hasBackCardTask;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CcIconButton.bouncing(
          onTap: () {
            controller.toggleCardStack();
            tabController.animateTo(controller.selectedTabIndex.value);
          },
          icon: Icon(
            isSecondaryFront
                ? Icons.keyboard_double_arrow_left_rounded
                : Icons.keyboard_double_arrow_right_rounded,
            size: context.respIconSize(baseSize: 16),
            color: scheme.onSurfaceVariant.withOpacity(0.4),
          ),
        ),
        if (showBadgeOnReveal)
          Positioned(
            bottom: 0,
            right: 0,
            child: PrjGuidelineBadge(
              size: 6,
              label: showLabelOnReveal ? guideline.bannerDescription : null,
              labelAbove: false,
              growRight: false,
            ),
          ),
      ],
    );
  }
}
