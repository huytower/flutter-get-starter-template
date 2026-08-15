import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/wallet_icon_helper.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
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
        CcSymmetricPadding(
          horizontal: CcPaddingParams.PAGE_SM,
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
            return _buildShimmerList(context);
          }

          // Capture items list to track its changes in this scope.
          final items = controller.mergedItems;

          if (items.isEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: context.respDim(20),
                horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
              ),
              child: CcText(
                el.tr(CcLocaleKeys.transaction_no_investment_items_hint),
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant.withOpacity(
                    0.6,
                  ),
                  fontStyle: FontStyle.italic,
                ),
                align: Alignment.center,
                textAlign: TextAlign.center,
              ),
            );
          }

          return HorizontalFadeScrollView(
            height: context.respDim(90),
            builder: (scrollController) => ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
              ),
              itemCount: items.length,
              separatorBuilder: (context, index) => const CcSpaceSM(),
              itemBuilder: (context, index) {
                final item = items[index];
                return Obx(() {
                  if (item is WalletEntity) {
                    final isSelected =
                        controller.selectedInvestmentWalletId.value == item.id;
                    return _buildItem(
                      context,
                      label: item.name,
                      icon: iconDataFromCode(item.iconCode),
                      isSelected: isSelected,
                      onTap: () => controller.selectAsset(item),
                    );
                  } else if (item is CategoryEntity) {
                    final isSelected =
                        controller.selectedCategory.value?.id == item.id &&
                        controller.isAddingNewItem.value;
                    return _buildItem(
                      context,
                      label: el.tr(item.nameKey),
                      icon: iconDataFromCode(
                        item.iconCode,
                        fontFamily: item.iconFamily,
                      ),
                      isSelected: isSelected,
                      onTap: () => controller.selectCategory(item),
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
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final scheme = context.ccColorScheme;

    return CcInkWell(
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

  Widget _buildShimmerList(BuildContext context) {
    return SizedBox(
      height: context.respDim(70),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
        ),
        itemCount: 5,
        separatorBuilder: (context, index) => const CcSpaceSM(),
        itemBuilder: (context, index) => Container(
          width: context.respDim(68),
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
                width: context.respDim(40),
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
