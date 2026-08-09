import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../domain/usecases/create_investment_transaction_usecase.dart';
import '../get_x/investment_form_controller.dart';
import 'category_selection_section.dart';
import 'cc_amount_input_section.dart';
import 'cc_form_label.dart';
import 'investment_direction_toggle.dart';
import 'money_keypad_panel.dart';
import 'transaction_additional_details_section.dart';
import 'transaction_submit_button.dart';
import 'transaction_wallet_selector.dart';

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

  // Mirrors report_page.dart: outflow (Chi ra) is the shaded half-alpha
  // leg, inflow (Thu vào) is the full-strength color.
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
      // Tap on the body (outside the keypad) dismisses the keypad / keyboard.
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
            _buildCategorySection(controller, accentColor),
            const CcSpaceLG(),
            _buildItemSection(context, controller, accentColor),
            const CcSpaceLG(),
            _buildFormFields(context, controller, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return CategorySelectionSection(
      key: ValueKey(controller.categoryKey.value),
      type: CategoryType.investment,
      activeColor: accentColor,
      autoSelectFirst: true,
      onCategorySelected: controller.setCategory,
    );
  }

  Widget _buildItemSection(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    if (controller.selectedCategory.value == null) {
      return const SizedBox.shrink();
    }

    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_SM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcFormLabel(text: el.tr(CcLocaleKeys.transaction_investment_item)),
          const CcSpaceXS(),
          if (controller.isAddingNewItem.value)
            controller.isVip.value
                ? _buildNewItemInput(context, controller, accentColor)
                : _buildVipLockedNameHint(context, controller, accentColor)
          else if (controller.investmentItems.isEmpty &&
              controller.direction.value == InvestmentDirection.returnProfit)
            _buildEmptyItemsHint(context)
          else
            TransactionWalletSelector(
              wallets: controller.investmentItems,
              selectedWalletId: controller.selectedInvestmentWalletId.value,
              activeColor: accentColor,
              onWalletSelected: controller.selectInvestmentItem,
              onAddNew:
                  controller.isVip.value &&
                      controller.direction.value ==
                          InvestmentDirection.contribute
                  ? controller.startAddingNewItem
                  : null,
              addNewLabel: el.tr(
                CcLocaleKeys.transaction_add_new_investment_item,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewItemInput(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: CcTextField(
            controller: controller.newItemNameController,
            hintText: el.tr(CcLocaleKeys.transaction_new_investment_item_hint),
            maxLines: 1,
            onChanged: controller.setNewItemName,
          ),
        ),
        const CcSpaceXS(),
        CcIconButton.bouncing(
          icon: Icon(
            Icons.close_rounded,
            size: context.respIconSize(baseSize: 20),
            color: context.ccColorScheme.onSurfaceVariant,
          ),
          onTap: controller.cancelAddingNewItem,
        ),
      ],
    );
  }

  /// Free-tier read-only substitute for [_buildNewItemInput]: the item name
  /// is fixed to the category's own label — no text field to edit it.
  Widget _buildVipLockedNameHint(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(12),
        vertical: context.respPadding(10),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.onSurface.withAlpha(10),
        borderRadius: context.brMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: context.respIconSize(baseSize: 18),
            color: accentColor,
          ),
          const CcSpaceXS(),
          Expanded(
            child: CcText(
              el.tr(
                CcLocaleKeys.transaction_investment_item_vip_locked,
                namedArgs: {'name': controller.newItemName.value},
              ),
              textStyle: context.ccTextTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyItemsHint(BuildContext context) {
    return CcText(
      el.tr(CcLocaleKeys.transaction_no_investment_items_hint),
      textStyle: context.ccTextTheme.bodyMedium?.copyWith(
        color: context.ccColorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildFormFields(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_SM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  /// Called for both directions — Chi ra debits this wallet, Thu vào
  /// credits it (real profit lands in real spendable cash).
  Widget _buildWalletSection(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    final labelKey = controller.direction.value == InvestmentDirection.contribute
        ? CcLocaleKeys.transaction_source_investment
        : CcLocaleKeys.transaction_destination_investment;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: el.tr(labelKey)),
        const CcSpaceXS(),
        TransactionWalletSelector(
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
