import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../wallet/export_wallet.dart';
import '../../domain/usecases/create_investment_transaction_usecase.dart';
import '../get_x/investment_form_controller.dart';
import 'cc_amount_input_section.dart';
import 'cc_form_label.dart';
import 'investment_asset_selector.dart';
import 'investment_direction_toggle.dart';
import 'money_keypad_panel.dart';
import 'transaction_additional_details_section.dart';
import 'transaction_form_container.dart';
import 'transaction_submit_button.dart';

class InvestmentForm extends StatelessWidget {
  const InvestmentForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Pre-registered by TransactionController.onInit() — see that call
    // site's comment for why this must be Get.find, not Get.put (this form
    // has no tagged/edit-mode variant, so there's never a second instance
    // to create here).
    final controller = Get.find<InvestmentFormController>();

    return Obx(() {
      final accentColor = _accentColor(context, controller.direction.value);

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

  Color _accentColor(BuildContext context, InvestmentDirection direction) =>
      direction == InvestmentDirection.contribute
      ? context.ccColorScheme.investment
      : context.ccColorScheme.investmentSecondary;

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
          vertical: context.respPadding(CcPaddingParams.SPACE_LG),
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
            InvestmentAssetSelector(
              controller: controller,
              activeColor: accentColor,
            ),
            const CcSpaceLG(),
            _buildFormFields(context, controller, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return TransactionFormContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => _buildAmountSection(context, controller, accentColor)),
          const CcSpaceLG(),
          Obx(() => _buildWalletSection(context, controller, accentColor)),
          const CcSpaceLG(),
          Obx(() {
            if (controller.isAddingNewItem.value) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNewItemNameField(context, controller, accentColor),
                  const CcSpaceLG(),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
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
          Obx(
            () => TransactionSubmitButton(
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
          ),
          const CcSpaceLG(),
        ],
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
        CcFormLabel(text: el.tr(CcLocaleKeys.transaction_investment_item)),
        const CcSpaceSM(),
        TextField(
          controller: controller.newItemNameController,
          enabled: controller.isVip.value,
          onChanged: controller.setNewItemName,
          style: context.ccTextTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: el.tr(CcLocaleKeys.transaction_new_investment_item_hint),
            border: OutlineInputBorder(borderRadius: context.brMd),
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.respDim(12),
              vertical: context.respDim(10),
            ),
            suffixIcon: !controller.isVip.value
                ? Tooltip(
                    message: el.tr(
                      CcLocaleKeys.transaction_investment_item_vip_locked,
                      namedArgs: {
                        'name': el.tr(
                          controller.selectedCategory.value?.nameKey ?? '',
                        ),
                      },
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: context.ccColorScheme.outline,
                    ),
                  )
                : null,
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
      onClear: () => controller.amountStr.value = '0',
      onCopy: () => CcStringHelper.copyToClipboard(controller.amountStr.value),
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
        const CcSpaceSM(),
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
