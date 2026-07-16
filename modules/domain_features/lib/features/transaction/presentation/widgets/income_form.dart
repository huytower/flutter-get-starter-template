import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../get_x/income_form_controller.dart';
import 'category_selection_section.dart';
import 'cc_amount_input_section.dart';
import 'cc_form_label.dart';
import 'money_keypad_panel.dart';
import 'transaction_additional_details_section.dart';
import 'transaction_submit_button.dart';
import 'transaction_wallet_selector.dart';

class IncomeForm extends StatelessWidget {
  final VoidCallback? onSaved;

  const IncomeForm({super.key, this.onSaved});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(getIt<IncomeFormController>());

    if (onSaved != null) {
      ever(controller.isSubmitting, (bool submitting) {
        if (!submitting && controller.amountStr.value == '0') {
          onSaved!();
        }
      });
    }

    final accentColor = PrjColors.success;

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
    IncomeFormController controller,
    Color accentColor,
  ) {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildCategorySection(
    IncomeFormController controller,
    Color accentColor,
  ) {
    return CategorySelectionSection(
      key: ValueKey(controller.categoryKey.value),
      type: CategoryType.income,
      activeColor: accentColor,
      autoSelectFirst: true,
      onCategorySelected: controller.setCategory,
    );
  }

  Widget _buildFormFields(
    BuildContext context,
    IncomeFormController controller,
    Color accentColor,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
      ),
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
            text: el.tr(CcLocaleKeys.transaction_record_income),
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
    IncomeFormController controller,
    Color accentColor,
  ) {
    return CcAmountInputSection(
      label: el.tr(CcLocaleKeys.transaction_amount),
      amountStr: controller.amountStr.value,
      quickAmounts: controller.quickAmounts,
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
    IncomeFormController controller,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: el.tr(CcLocaleKeys.transaction_source_income)),
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
    IncomeFormController controller,
    Color accentColor,
  ) {
    return SafeArea(
      top: false,
      child: MoneyKeypadPanel(
        onKeyPress: controller.handleKeyPress,
        onDelete: controller.handleDelete,
        onClear: () => controller.amountStr.value = '0',
        suggestions: controller.quickAmounts,
        onSuggestion: (value) => controller.amountStr.value = value.toString(),
        onDone: controller.hideKeypad,
        activeColor: accentColor,
      ),
    );
  }
}
