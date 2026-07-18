import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/util/money_constants.dart';
import '../get_x/expense_form_controller.dart';
import 'category_selection_section.dart';
import 'cc_amount_input_section.dart';
import 'cc_form_label.dart';
import 'money_keypad_panel.dart';
import 'transaction_additional_details_section.dart';
import 'transaction_submit_button.dart';
import 'transaction_wallet_selector.dart';

class ExpenseForm extends StatelessWidget {
  const ExpenseForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Register the controller if not already present.
    // Usually TransactionPage or a Binding would do this, but for modularity
    // we can use Get.put here or Get.find if it's already there.
    final controller = Get.put(getIt<ExpenseFormController>());

    final accentColor = context.ccColorScheme.error;

    return Obx(
      () => Column(
        children: [
          Expanded(
            child: _buildScrollableContent(context, controller, accentColor),
          ),
          if (controller.showKeypad.value)
            _buildMoneyKeypadPanel(context, controller, accentColor),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(
    BuildContext context,
    ExpenseFormController controller,
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
            _buildCategorySection(controller, accentColor),
            const CcSpaceLG(),
            _buildFormFields(context, controller, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    ExpenseFormController controller,
    Color accentColor,
  ) {
    return CategorySelectionSection(
      key: ValueKey(controller.categoryKey.value),
      activeColor: accentColor,
      autoSelectFirst: true,
      onCategorySelected: controller.setCategory,
    );
  }

  Widget _buildFormFields(
    BuildContext context,
    ExpenseFormController controller,
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
            text: el.tr(CcLocaleKeys.transaction_record_expense),
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
    ExpenseFormController controller,
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
    ExpenseFormController controller,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: el.tr(CcLocaleKeys.transaction_source_expense)),
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
    ExpenseFormController controller,
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
