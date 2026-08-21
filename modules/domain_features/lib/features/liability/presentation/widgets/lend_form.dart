import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
import '../../../transaction/presentation/widgets/transaction_additional_details_section.dart';
import '../../../transaction/presentation/widgets/transaction_form_container.dart';
import '../../../transaction/presentation/widgets/transaction_submit_button.dart';
import '../../../wallet/export_wallet.dart';
import '../get_x/lend_form_controller.dart';
import '../get_x/liability_form_controller.dart';
import 'liability_asset_selector.dart';
import 'liability_pill_toggle.dart';
import 'liability_repayment_method_section.dart';

class LendForm extends StatelessWidget {
  const LendForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LendFormController>();

    return Obx(() {
      final accentColor = context.ccColorScheme.debtLoanSecondary;

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

  Widget _buildScrollableContent(
    BuildContext context,
    LendFormController controller,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        controller.hideKeypad();
      },
      child: SingleChildScrollView(
        controller: controller.scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildInitiateSection(context, controller, accentColor)],
        ),
      ),
    );
  }

  Widget _buildInitiateSection(
    BuildContext context,
    LendFormController controller,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LiabilityPillToggle(
          selectedIndex: controller.action.value == LiabilityAction.initiate
              ? 0
              : 1,
          firstLabel: el.tr(CcLocaleKeys.transaction_loan_direction_lend),
          secondLabel: el.tr(CcLocaleKeys.transaction_record_collect),
          activeColor: accentColor,
          onChanged: (index) => controller.setAction(
            index == 0 ? LiabilityAction.initiate : LiabilityAction.settle,
          ),
        ),
        const CcSpaceSM(),
        LiabilityAssetSelector(
          // LiabilityAssetSelector currently expects LiabilityFormController.
          // I might need to make it generic or update it to take dynamic controller.
          // Let's check it.
          controller: controller as dynamic,
          activeColor: accentColor,
        ),
        const CcSpaceSM(),
        TransactionFormContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAmountSection(context, controller, accentColor),
              const CcSpaceSM(),
              _buildWalletSection(context, controller, accentColor),
              const CcSpaceSM(),
              Obx(() {
                final loan = controller.mergedItems
                    .firstWhereOrNull(
                      (b) => b.liability.id == controller.selectedLoanId.value,
                    )
                    ?.liability;

                if (loan != null && loan.principalAmount == 0) {
                  return Column(
                    children: [
                      LiabilityRepaymentMethodSection(
                        controller: controller as dynamic,
                        accentColor: accentColor,
                      ),
                      const CcSpaceSM(),
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
              const CcSpaceSM(),
              TransactionSubmitButton(
                text: el.tr(CcLocaleKeys.transaction_record_liability),
                isSubmitting: controller.isSubmitting.value,
                isEnabled: controller.canSubmit,
                onTap: () => controller.submitForm(context),
                activeColor: accentColor,
              ),
              const CcSpaceXS(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(
    BuildContext context,
    LendFormController controller,
    Color accentColor,
  ) {
    return Obx(() {
      final bool isInitiate =
          controller.action.value == LiabilityAction.initiate;

      final label = !isInitiate
          ? el.tr(CcLocaleKeys.transaction_amount)
          : el.tr(CcLocaleKeys.transaction_liability_amount_lend_label);

      return CcAmountInputSection(
        label: label,
        amountStr: controller.amountStr.value,
        quickAmounts: MoneyConstants.quickAmounts,
        isKeypadVisible: controller.showKeypad.value,
        activeColor: accentColor,
        fieldKey: controller.amountFieldKey,
        onTap: () => controller.showKeypadAndScroll(context),
        onQuickAmountSelected: (amount) =>
            controller.amountStr.value = amount.toString(),
        onClear: controller.handleClear,
        onCopy: () =>
            CcStringHelper.copyToClipboard(controller.amountStr.value),
      );
    });
  }

  Widget _buildWalletSection(
    BuildContext context,
    LendFormController controller,
    Color accentColor,
  ) {
    return Obx(() {
      final bool isInitiate =
          controller.action.value == LiabilityAction.initiate;

      final label = !isInitiate
          ? el.tr(CcLocaleKeys.transaction_source_debt)
          : el.tr(CcLocaleKeys.transaction_liability_wallet_lend_label);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcFormLabel(text: label),
          const CcSpaceXS(),
          WalletStripCard(
            wallets: controller.wallets,
            selectedWalletId: controller.selectedWalletId.value,
            activeColor: accentColor,
            defaultBgColor: context.verticalGradient(accentColor),
            onWalletSelected: controller.setWalletId,
          ),
        ],
      );
    });
  }

  Widget _buildMoneyKeypadPanel(
    BuildContext context,
    LendFormController controller,
    Color accentColor,
  ) {
    return MoneyKeypadPanel(
      onKeyPress: controller.handleKeyPress,
      onDelete: controller.handleDelete,
      onClear: controller.handleClear,
      suggestions: MoneyConstants.quickAmounts,
      onSuggestion: (value) => controller.handleSuggestion(value),
      onDone: controller.hideKeypad,
      activeColor: accentColor,
    );
  }
}
