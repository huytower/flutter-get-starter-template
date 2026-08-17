import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/loan_form_controller.dart';

class LoanAssetSelector extends StatelessWidget {
  final LoanFormController controller;
  final Color activeColor;

  const LoanAssetSelector({
    super.key,
    required this.controller,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcSymmetricPadding(
          horizontal: CcPaddingParams.PAGE_SM,
          child: CcText(
            el.tr(CcLocaleKeys.loan_list_title),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const CcSpaceSM(),
        Obx(() {
          if (controller.isLoadingMerged.value) {
            return _buildShimmerList(context);
          }

          final items = controller.mergedItems;

          if (items.isEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: context.respDim(20),
                horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
              ),
              child: CcText(
                el.tr(CcLocaleKeys.loan_empty_state),
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant.withAlpha(50),
                  fontStyle: FontStyle.italic,
                ),
                align: Alignment.center,
                textAlign: TextAlign.center,
              ),
            );
          }

          return HorizontalFadeScrollView(
            height: context.respDim(95),
            builder: (scrollController) => ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
                vertical: context.respDim(4),
              ),
              itemCount: items.length,
              separatorBuilder: (context, index) => const CcSpaceMD(),
              itemBuilder: (context, index) {
                final balance = items[index];
                final loan = balance.loan;
                final isSelected = controller.selectedLoanId.value == loan.id;

                return CcInkWell(
                  onTap: () => controller.selectLoan(balance),
                  borderRadius: context.brLg,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (isSelected)
                        Positioned.fill(
                          child: CcGlassyGradientBackground(
                            centerColor: activeColor.withAlpha(30),
                            endColor: activeColor.withAlpha(50),
                          ),
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: context.respDim(160),
                        padding: EdgeInsets.all(context.respDim(10)),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeColor.withAlpha(10)
                              : context.ccColorScheme.onSurface.withAlpha(10),
                          borderRadius: context.brLg,
                          border: Border.all(
                            color: isSelected
                                ? activeColor.withAlpha(20)
                                : context.ccColorScheme.onSurface.withAlpha(10),
                            width: context.respDim(1),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIcon(context, loan, isSelected),
                            const CcSpaceXS(),
                            CcText(
                              loan.categoryLabel,
                              textAlign: TextAlign.center,
                              align: Alignment.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textStyle: context.ccTextTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? activeColor
                                        : context
                                              .ccColorScheme
                                              .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildIcon(BuildContext context, dynamic loan, bool isSelected) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(35),
      height: context.respDim(35),
      decoration: BoxDecoration(
        color: isSelected
            ? activeColor.withAlpha(20)
            : scheme.onSurface.withAlpha(10),
        borderRadius: context.brMd,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected)
            Positioned.fill(
              child: CcGlassyGradientIcon(
                centerColor: activeColor.withAlpha(30),
                endColor: activeColor.withAlpha(50),
              ),
            ),
          CcIcon(
            icon: iconDataFromCode(
              loan.categoryIconCode ?? 0,
              fontFamily: loan.categoryIconFamily,
            ),
            size: context.respIconSize(baseSize: 18),
            color: isSelected ? activeColor : scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    return SizedBox(
      height: context.respDim(95),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
          vertical: context.respDim(4),
        ),
        itemCount: 5,
        separatorBuilder: (context, index) => const CcSpaceMD(),
        itemBuilder: (context, index) => Container(
          width: context.respDim(160),
          padding: EdgeInsets.all(context.respDim(10)),
          decoration: BoxDecoration(
            color: context.ccColorScheme.onSurface.withAlpha(10),
            borderRadius: context.brLg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CcShimmer(
                width: context.respDim(35),
                height: context.respDim(35),
                borderRadius: context.brMd,
              ),
              const CcSpaceXS(),
              CcShimmer(
                width: context.respDim(80),
                height: context.respDim(10),
                borderRadius: context.brXs,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
