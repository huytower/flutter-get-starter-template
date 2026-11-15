import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/budget_name_helper.dart';
import '../../../transaction/presentation/helper/horizontal_row_reveal.dart';
import '../../../transaction/presentation/widgets/base/category_customize_empty_state.dart';
import '../get_x/lend_form_controller.dart';
import '../pages/lend_list_page.dart';

class LendAssetSelector extends StatelessWidget {
  final LendFormController controller;
  final Color activeColor;

  const LendAssetSelector({
    super.key,
    required this.controller,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcContentPadding(
          child: CcSymmetricPadding(
            horizontal: CcPaddingParams.PAGE_XS,
            child: CcText(
              el.tr(CcLocaleKeys.transaction_category),
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const CcSpaceXS(),
        Obx(() {
          if (controller.isLoadingMerged.value) {
            return const CcContentPadding(
              child: CcCategoryShimmerList(itemPadding: EdgeInsets.zero),
            );
          }

          final items = controller.mergedItems;

          // The customize cell is only offered while there is nothing to
          // pick; it opens the lend list with the add sheet on top.
          if (items.isEmpty) {
            return CcContentPadding(
              child: CategoryCustomizeEmptyState(
                hint: el.tr(CcLocaleKeys.liability_empty_state),
                onCustomize: () => LendListPage.open(context, openAdd: true),
              ),
            );
          }

          return HorizontalFadeScrollView(
            height: context.respDim(100),
            scrollController: controller.assetRowScrollController,
            builder: (scrollController) => ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              // Starts aligned with the content, scrolls out to the screen edge.
              padding: EdgeInsetsDirectional.only(
                start:
                    context.respPadding(CcPaddingParams.PAGE_XS) +
                    CcContentInset.of(context),
                end: context.respPadding(CcPaddingParams.PAGE_XS),
                top: context.respDim(4),
                bottom: context.respDim(4),
              ),
              itemCount: items.length,
              separatorBuilder: (context, index) => const CcSpaceSM(),
              itemBuilder: (context, index) {
                final balance = items[index];
                final liability = balance.liability;

                return Obx(() {
                  final isSelected =
                      controller.selectedLiabilityId.value == liability.id;

                  final displayName = BudgetNameHelper.getDisplayName(
                    name: liability.categoryLabel,
                    categoryNameKey: liability.categoryNameKey,
                  );

                  return _buildItem(
                    context,
                    label: displayName,
                    icon: iconDataFromCode(
                      liability.categoryIconCode ?? 0,
                      fontFamily: liability.categoryIconFamily,
                    ),
                    isSelected: isSelected,
                    onTap: () {
                      controller.selectLiability(balance);
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
            width: context.respDim(assetCardWidth),
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
