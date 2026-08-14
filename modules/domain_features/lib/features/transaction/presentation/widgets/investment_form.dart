import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/helper/wallet_icon_helper.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/widgets/cc_wallet_strip_card.dart';
import '../../domain/usecases/create_investment_transaction_usecase.dart';
import '../get_x/investment_form_controller.dart';
import 'cc_amount_input_section.dart';
import 'cc_form_label.dart';
import 'investment_direction_toggle.dart';
import 'money_keypad_panel.dart';
import 'transaction_additional_details_section.dart';
import 'transaction_submit_button.dart';

class InvestmentForm extends StatelessWidget {
  const InvestmentForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(getIt<InvestmentFormController>());

    return Obx(() {
      final accentColor = _accentColor(controller.direction.value);

      return Column(
        children: [
          Expanded(
            child: _buildScrollableContent(context, controller, accentColor),
          ),
          if (controller.showKeypad.value)
            _buildMoneyKeypadPanel(context, controller, accentColor),
        ],
      );
    });
  }

  Color _accentColor(InvestmentDirection direction) =>
      direction == InvestmentDirection.contribute
      ? PrjColors.investment.withValues(alpha: 0.5)
      : PrjColors.investment;

  Widget _buildScrollableContent(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        controller.hideKeypad();
      },
      child: SingleChildScrollView(
        controller: controller.scrollController,
        padding: EdgeInsets.symmetric(
          vertical: context.respPadding(CcPaddingParams.PAGE_XS),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InvestmentDirectionToggle(
              value: controller.direction.value,
              activeColor: accentColor,
              onChanged: controller.setDirection,
            ),
            const CcSpaceLG(),
            _buildMergedSelectionSection(context, controller, accentColor),
            const CcSpaceLG(),
            _buildFormFields(context, controller, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildMergedSelectionSection(
    BuildContext context,
    InvestmentFormController controller,
    Color activeColor,
  ) {
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

          return HorizontalFadeScrollView(
            height: context.respDim(70),
            builder: (scrollController) => ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
              ),
              itemCount: controller.mergedItems.length,
              separatorBuilder: (context, index) => const CcSpaceSM(),
              itemBuilder: (context, index) {
                final item = controller.mergedItems[index];
                if (item is WalletEntity) {
                  final isSelected =
                      controller.selectedInvestmentWalletId.value == item.id;
                  return _buildAssetItem(
                    context,
                    item,
                    isSelected,
                    controller,
                    activeColor,
                  );
                } else if (item is CategoryEntity) {
                  final isSelected =
                      controller.selectedCategory.value?.id == item.id &&
                      controller.isAddingNewItem.value;
                  return _buildCategoryItem(
                    context,
                    item,
                    isSelected,
                    controller,
                    activeColor,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAssetItem(
    BuildContext context,
    WalletEntity wallet,
    bool isSelected,
    InvestmentFormController controller,
    Color activeColor,
  ) {
    final scheme = context.ccColorScheme;
    return CcInkWell(
      onTap: () => controller.selectAsset(wallet),
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
                _buildIconContainer(
                  context,
                  iconDataFromCode(wallet.iconCode),
                  isSelected,
                  activeColor,
                ),
                const CcSpaceXS(),
                CcText(
                  wallet.name,
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

  Widget _buildCategoryItem(
    BuildContext context,
    CategoryEntity category,
    bool isSelected,
    InvestmentFormController controller,
    Color activeColor,
  ) {
    final scheme = context.ccColorScheme;
    return CcInkWell(
      onTap: () => controller.selectCategory(category),
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
                  : scheme.onSurface.withAlpha(5),
              borderRadius: context.brLg,
              border: Border.all(
                color: isSelected
                    ? activeColor.withAlpha(20)
                    : scheme.onSurface.withAlpha(5),
                width: context.respDim(1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconContainer(
                  context,
                  iconDataFromCode(
                    category.iconCode,
                    fontFamily: category.iconFamily,
                  ),
                  isSelected,
                  activeColor,
                  isCategory: true,
                ),
                const CcSpaceXS(),
                CcText(
                  el.tr(category.nameKey),
                  textAlign: TextAlign.center,
                  align: Alignment.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textStyle: context.ccTextTheme.labelSmall?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? activeColor
                        : scheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(
    BuildContext context,
    IconData icon,
    bool isSelected,
    Color activeColor, {
    bool isCategory = false,
  }) {
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
          Icon(
            icon,
            size: context.respIconSize(baseSize: 18),
            color: isSelected
                ? activeColor
                : scheme.onSurfaceVariant.withOpacity(isCategory ? 0.5 : 1.0),
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

  Widget _buildFormFields(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    final scheme = context.ccColorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: context.brLg,
        border: Border.all(
          color: scheme.onSurface.withOpacity(0.08),
          width: context.respDim(1),
        ),
      ),
      child: CcPadding(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.isVip.value &&
                controller.isAddingNewItem.value &&
                controller.selectedCategory.value != null) ...[
              _buildNewItemNameField(context, controller, accentColor),
              const CcSpaceLG(),
            ],
            _buildAmountSection(context, controller, accentColor),
            const CcSpaceLG(),
            _buildWalletSection(context, controller, accentColor),
            const CcSpaceLG(),
            TransactionAdditionalDetailsSection(
              isExpanded: controller.showMoreDetails.value,
              onToggle: controller.toggleMoreDetails,
              selectedDate: controller.date.value,
              onDateSelected: controller.setDate,
              onCalendarTap: () => controller.pickDate(context),
              noteController: controller.noteController,
              hasNoteText: controller.noteController.text.isNotEmpty,
              activeColor: accentColor,
            ),
            const CcSpaceXL(),
            TransactionSubmitButton(
              text: el.tr(
                controller.direction.value == InvestmentDirection.contribute
                    ? CcLocaleKeys.transaction_record_investment
                    : CcLocaleKeys.transaction_record_investment_return,
              ),
              isSubmitting: controller.isSubmitting.value,
              isEnabled: controller.canSubmit,
              onTap: () => controller.submitForm(context),
              activeColor: accentColor,
            ),
            const CcSpaceLG(),
          ],
        ),
        6,
        12,
        12,
        6,
      ),
    );
  }

  Widget _buildNewItemNameField(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: el.tr(CcLocaleKeys.wallet_investment_name)),
        const CcSpaceXS(),
        TextField(
          controller: controller.newItemNameController,
          onChanged: controller.setNewItemName,
          decoration: InputDecoration(
            hintText: el.tr(CcLocaleKeys.wallet_investment_name_hint),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return CcAmountInputSection(
      label: el.tr(CcLocaleKeys.transaction_amount),
      amountStr: controller.amountStr.value,
      quickAmounts: MoneyConstants.quickAmounts,
      isKeypadVisible: controller.showKeypad.value,
      activeColor: accentColor,
      fieldKey: controller.amountFieldKey,
      onTap: () => controller.showKeypadAndScroll(context),
      onQuickAmountSelected: (amount) =>
          controller.amountStr.value = amount.toString(),
    );
  }

  Widget _buildWalletSection(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    final labelKey =
        controller.direction.value == InvestmentDirection.contribute
        ? CcLocaleKeys.transaction_source_investment
        : CcLocaleKeys.transaction_destination_investment;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: el.tr(labelKey)),
        const CcSpaceXS(),
        CcWalletStripCard(
          wallets: controller.wallets,
          selectedWalletId: controller.selectedWalletId.value,
          activeColor: accentColor,
          onWalletSelected: controller.setWalletId,
        ),
      ],
    );
  }

  Widget _buildMoneyKeypadPanel(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return MoneyKeypadPanel(
      onKeyPress: controller.handleKeyPress,
      onDelete: controller.handleDelete,
      onClear: () => controller.amountStr.value = '0',
      suggestions: MoneyConstants.quickAmounts,
      onSuggestion: (value) => controller.amountStr.value = value.toString(),
      onDone: controller.hideKeypad,
      activeColor: accentColor,
    );
  }
}
