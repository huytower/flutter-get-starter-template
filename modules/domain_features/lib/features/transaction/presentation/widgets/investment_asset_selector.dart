import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/presentation/helper/asset_card_metrics.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:domain_features/features/transaction/presentation/widgets/base/category_customize_empty_state.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/budget/budget_name_helper.dart';
import '../../../wallet/presentation/pages/investment_list_page.dart';
import '../get_x/investment_form_controller.dart';

class InvestmentAssetSelector extends StatelessWidget {
  final InvestmentFormController controller;
  final Color activeColor;

  const InvestmentAssetSelector({
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
              el.tr(PrjLocaleKeys.transaction_category),
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const CcSpaceXS(),
        Obx(() {
          if (controller.hasLoadingMerged.value) {
            return CcContentPadding(
              child: CcShimmerList(
                height: context.respDim(95),
                verticalPadding: context.respDim(4),
                separator: const CcSpaceMD(),
              ),
            );
          }

          // Capture items list to track its changes in this scope.
          final items = controller.mergedItems;

          // The customize cell is only offered while there is nothing to
          // pick; it opens the investment list with the add sheet on top.
          if (items.isEmpty) {
            return CcContentPadding(
              child: CategoryCustomizeEmptyState(
                hint: el.tr(PrjLocaleKeys.transaction_no_investment_items_hint),
                onCustomize: () =>
                    InvestmentListPage.open(context, openAdd: true),
              ),
            );
          }

          return CcHorizontalFadeScrollView(
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
                final item = items[index];
                return Obx(() {
                  if (item is WalletEntity) {
                    final hasSelected =
                        controller.selectedInvestmentWalletId.value == item.id;
                    final displayName = BudgetNameHelper.getDisplayName(
                      name: item.name,
                      categoryNameKey: item.categoryNameKey,
                    );
                    return _buildItem(
                      context,
                      label: displayName,
                      icon: iconDataFromCode(item.iconCode),
                      hasSelected: hasSelected,
                      onTap: () => controller.selectInvestmentWallet(item),
                    );
                  } else if (item is CategoryEntity) {
                    final hasSelected =
                        controller.selectedCategory.value?.id == item.id &&
                        controller.hasAddingNewItem.value;
                    final displayName = el.tr(item.nameKey);
                    return _buildItem(
                      context,
                      label: displayName,
                      icon: iconDataFromCode(
                        item.iconCode,
                        fontFamily: item.iconFamily,
                      ),
                      hasSelected: hasSelected,
                      onTap: () => controller.selectInvestmentCategory(item),
                    );
                  }
                  return const SizedBox.shrink();
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
    required bool hasSelected,
    required VoidCallback onTap,
  }) {
    final scheme = context.ccColorScheme;

    return CcBouncing(
      onTap: onTap,
      borderRadius: context.brLg,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (hasSelected)
            Positioned.fill(
              child: CcGlassyGradientBackground(
                centerColor: activeColor.withAlpha(30),
                endColor: activeColor.withAlpha(50),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: context.respDim(AssetCardMetrics.width),
            padding: EdgeInsets.all(context.respDim(10)),
            decoration: BoxDecoration(
              color: hasSelected
                  ? activeColor.withAlpha(10)
                  : scheme.onSurface.withAlpha(10),
              borderRadius: context.brLg,
              border: Border.all(
                color: hasSelected
                    ? activeColor.withAlpha(20)
                    : scheme.onSurface.withAlpha(10),
                width: context.respDim(1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(context, icon, hasSelected),
                const CcSpaceXS(),
                CcText(
                  label,
                  textAlign: TextAlign.center,
                  align: Alignment.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textStyle: context.ccTextTheme.labelSmall?.copyWith(
                    fontWeight: hasSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: hasSelected ? activeColor : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context, IconData icon, bool hasSelected) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(35),
      height: context.respDim(35),
      decoration: BoxDecoration(
        color: hasSelected
            ? activeColor.withAlpha(20)
            : scheme.onSurface.withAlpha(10),
        borderRadius: context.brMd,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasSelected)
            Positioned.fill(
              child: CcGlassyGradientIcon(
                centerColor: activeColor.withAlpha(30),
                endColor: activeColor.withAlpha(50),
              ),
            ),
          CcIcon(
            icon: icon,
            size: context.respIconSize(baseSize: 18),
            color: hasSelected ? activeColor : scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
