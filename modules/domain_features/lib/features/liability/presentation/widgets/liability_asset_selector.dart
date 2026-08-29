import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/liability_base_form_controller.dart';

class LiabilityAssetSelector extends StatelessWidget {
  final LiabilityBaseFormController controller;
  final Color activeColor;

  const LiabilityAssetSelector({
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
          horizontal: CcPaddingParams.PAGE_XS,
          child: CcText(
            el.tr(CcLocaleKeys.transaction_category),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const CcSpaceXS(),
        Obx(() {
          if (controller.isLoadingMerged.value) {
            return CcCategoryShimmerList(
              height: context.respDim(95),
              verticalPadding: context.respDim(4),
              separator: const CcSpaceMD(),
            );
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
                el.tr(CcLocaleKeys.liability_empty_state),
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
            height: context.respDim(100),
            builder: (scrollController) => ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: context.respPadding(CcPaddingParams.PAGE_XS),
                vertical: context.respDim(4),
              ),
              itemCount: items.length,
              separatorBuilder: (context, index) => const CcSpaceMD(),
              itemBuilder: (context, index) {
                final balance = items[index];
                final liability = balance.liability;

                return Obx(() {
                  final isSelected = controller.selectedLoanId.value == liability.id;

                  return _buildItem(
                    context,
                    label: liability.categoryLabel,
                    icon: iconDataFromCode(
                      liability.categoryIconCode ?? 0,
                      fontFamily: liability.categoryIconFamily,
                    ),
                    isSelected: isSelected,
                    onTap: () {
                      debugPrint(
                        '[LIABILITY_ASSET_SELECTOR] Tapped liability: id=${liability.id}, label=${liability.categoryLabel}, selected=$isSelected',
                      );
                      controller.selectLoan(balance);
                    },
                  );
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final scheme = context.ccColorScheme;

    return CcBouncing(
      onTap: onTap,
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
            width: context.respDim(68),
            padding: EdgeInsets.all(context.respDim(10)),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withAlpha(10)
                  : scheme.onSurface.withAlpha(10),
              borderRadius: context.brLg,
              border: Border.all(
                color: isSelected
                    ? activeColor.withAlpha(20)
                    : scheme.onSurface.withAlpha(10),
                width: context.respDim(1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(context, icon, isSelected),
                const CcSpaceXS(),
                CcText(
                  label,
                  textAlign: TextAlign.center,
                  align: Alignment.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textStyle: context.ccTextTheme.labelSmall?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? activeColor : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context, IconData icon, bool isSelected) {
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
            icon: icon,
            size: context.respIconSize(baseSize: 18),
            color: isSelected ? activeColor : scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
