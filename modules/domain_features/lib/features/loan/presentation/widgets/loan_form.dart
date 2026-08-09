import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../transaction/presentation/widgets/category_selection_section.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/cc_form_label.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
import '../../../transaction/presentation/widgets/transaction_additional_details_section.dart';
import '../../../transaction/presentation/widgets/transaction_submit_button.dart';
import '../../../transaction/presentation/widgets/transaction_wallet_selector.dart';
import '../../domain/entities/loan_entity.dart';
import '../get_x/loan_form_controller.dart';
import 'loan_counterparty_field.dart';
import 'loan_pill_toggle.dart';
import 'loan_repayment_method_section.dart';

class LoanForm extends StatelessWidget {
  const LoanForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(getIt<LoanFormController>());

    return Obx(() {
      final accentColor = _accentColor(controller);

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

  // Mirrors report_page.dart: borrow is inflow (full color), lend is
  // outflow (shaded half-alpha).
  Color _accentColor(LoanFormController controller) {
    final isBorrowSide = controller.direction.value == LoanDirection.borrow;
    return isBorrowSide
        ? PrjColors.debtLoan
        : PrjColors.debtLoan.withValues(alpha: 0.5);
  }

  Widget _buildScrollableContent(
    BuildContext context,
    LoanFormController controller,
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
          children: [_buildInitiateSection(context, controller, accentColor)],
        ),
      ),
    );
  }

  Widget _buildInitiateSection(
    BuildContext context,
    LoanFormController controller,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoanPillToggle(
          selectedIndex: controller.direction.value == LoanDirection.borrow
              ? 0
              : 1,
          firstLabel: el.tr(CcLocaleKeys.transaction_loan_direction_borrow),
          secondLabel: el.tr(CcLocaleKeys.transaction_loan_direction_lend),
          activeColor: accentColor,
          onChanged: (index) => controller.setDirection(
            index == 0 ? LoanDirection.borrow : LoanDirection.lend,
          ),
        ),
        const CcSpaceLG(),
        CategorySelectionSection(
          key: ValueKey(controller.categoryKey.value),
          type: CategoryType.debtLoan,
          groupIds: [
            controller.direction.value == LoanDirection.borrow
                ? CategorySeed.debtLoanBorrowGroupId
                : CategorySeed.debtLoanLendGroupId,
          ],
          activeColor: accentColor,
          autoSelectFirst: true,
          title: controller.direction.value == LoanDirection.borrow
              ? el.tr(CcLocaleKeys.transaction_loan_category_borrow_label)
              : el.tr(CcLocaleKeys.transaction_loan_category_lend_label),
          onCategorySelected: controller.setCategory,
        ),
        const CcSpaceLG(),
        CcSymmetricPadding(
          horizontal: CcPaddingParams.PAGE_SM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoanCounterpartyField(
                controller: controller,
                accentColor: accentColor,
              ),
              _buildAmountSection(context, controller, accentColor),
              const CcSpaceLG(),
              _buildWalletSection(context, controller, accentColor),
              const CcSpaceLG(),
              LoanRepaymentMethodSection(
                controller: controller,
                accentColor: accentColor,
              ),
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
                text: el.tr(CcLocaleKeys.transaction_record_loan),
                isSubmitting: controller.isSubmitting.value,
                isEnabled: controller.canSubmit,
                onTap: () => controller.submitForm(context),
                activeColor: accentColor,
              ),
              const CcSpaceLG(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(
    BuildContext context,
    LoanFormController controller,
    Color accentColor,
  ) {
    return CcAmountInputSection(
      label: controller.direction.value == LoanDirection.borrow
          ? el.tr(CcLocaleKeys.transaction_loan_amount_borrow_label)
          : el.tr(CcLocaleKeys.transaction_loan_amount_lend_label),
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
    LoanFormController controller,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(
          text: controller.direction.value == LoanDirection.borrow
              ? el.tr(CcLocaleKeys.transaction_loan_wallet_borrow_label)
              : el.tr(CcLocaleKeys.transaction_loan_wallet_lend_label),
        ),
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
    LoanFormController controller,
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
