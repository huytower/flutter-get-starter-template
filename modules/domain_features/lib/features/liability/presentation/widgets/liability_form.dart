import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/cc_form_label.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
import '../../../transaction/presentation/widgets/transaction_additional_details_section.dart';
import '../../../transaction/presentation/widgets/transaction_form_container.dart';
import '../../../transaction/presentation/widgets/transaction_submit_button.dart';
import '../../../wallet/presentation/widgets/cc_wallet_strip_card.dart';
import '../../domain/entities/liability_entity.dart';
import '../get_x/liability_form_controller.dart';
import 'liability_asset_selector.dart';
import 'liability_pill_toggle.dart';
import 'liability_repayment_method_section.dart';

class LiabilityForm extends StatelessWidget {
  const LiabilityForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Pre-registered by TransactionController.onInit() — see that call
    // site's comment for why this must be Get.find, not Get.put (this form
    // has no tagged/edit-mode variant, so there's never a second instance
    // to create here).
    final controller = Get.find<LiabilityFormController>();

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
  Color _accentColor(LiabilityFormController controller) {
    final isBorrowSide =
        controller.direction.value == LiabilityDirection.borrow;
    return isBorrowSide
        ? PrjColors.debtLoan
        : PrjColors.debtLoan.withValues(alpha: 0.5);
  }

  Widget _buildScrollableContent(
    BuildContext context,
    LiabilityFormController controller,
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
          children: [_buildInitiateSection(context, controller, accentColor)],
        ),
      ),
    );
  }

  Widget _buildInitiateSection(
    BuildContext context,
    LiabilityFormController controller,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LiabilityPillToggle(
          selectedIndex: controller.direction.value == LiabilityDirection.borrow
              ? 0
              : 1,
          firstLabel: el.tr(
            CcLocaleKeys.transaction_liability_direction_borrow,
          ),
          secondLabel: el.tr(CcLocaleKeys.transaction_liability_direction_lend),
          activeColor: accentColor,
          onChanged: (index) => controller.setDirection(
            index == 0 ? LiabilityDirection.borrow : LiabilityDirection.lend,
          ),
        ),
        const CcSpaceLG(),
        LiabilityAssetSelector(
          controller: controller,
          activeColor: accentColor,
        ),
        const CcSpaceLG(),
        TransactionFormContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAmountSection(context, controller, accentColor),
              const CcSpaceLG(),
              _buildWalletSection(context, controller, accentColor),
              const CcSpaceLG(),
              Obx(() {
                final loan = controller.mergedItems
                    .firstWhereOrNull(
                      (b) => b.liability.id == controller.selectedLoanId.value,
                    )
                    ?.liability;

                // Only show schedule editor if it's a new loan (0 principal)
                if (loan != null && loan.principalAmount == 0) {
                  return Column(
                    children: [
                      LiabilityRepaymentMethodSection(
                        controller: controller,
                        accentColor: accentColor,
                      ),
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
              TransactionSubmitButton(
                text: el.tr(CcLocaleKeys.transaction_record_liability),
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
    LiabilityFormController controller,
    Color accentColor,
  ) {
    return Obx(() {
      final loan = controller.mergedItems
          .firstWhereOrNull(
            (b) => b.liability.id == controller.selectedLoanId.value,
          )
          ?.liability;
      final isExisting = loan != null && loan.principalAmount > 0;

      final label = isExisting
          ? el.tr(CcLocaleKeys.transaction_amount)
          : (controller.direction.value == LiabilityDirection.borrow
                ? el.tr(CcLocaleKeys.transaction_liability_amount_borrow_label)
                : el.tr(CcLocaleKeys.transaction_liability_amount_lend_label));

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
    LiabilityFormController controller,
    Color accentColor,
  ) {
    return Obx(() {
      final loan = controller.mergedItems
          .firstWhereOrNull(
            (b) => b.liability.id == controller.selectedLoanId.value,
          )
          ?.liability;
      final isExisting = loan != null && loan.principalAmount > 0;

      final label = isExisting
          ? el.tr(CcLocaleKeys.transaction_source_debt)
          : (controller.direction.value == LiabilityDirection.borrow
                ? el.tr(CcLocaleKeys.transaction_liability_wallet_borrow_label)
                : el.tr(CcLocaleKeys.transaction_liability_wallet_lend_label));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcFormLabel(text: label),
          const CcSpaceSM(),
          CcWalletStripCard(
            wallets: controller.wallets,
            selectedWalletId: controller.selectedWalletId.value,
            activeColor: accentColor,
            onWalletSelected: controller.setWalletId,
          ),
        ],
      );
    });
  }

  Widget _buildMoneyKeypadPanel(
    BuildContext context,
    LiabilityFormController controller,
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
