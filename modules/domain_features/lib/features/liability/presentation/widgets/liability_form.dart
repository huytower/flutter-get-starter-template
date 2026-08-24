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
import '../../domain/entities/liability_entity.dart';
import '../get_x/liability_form_controller.dart';
import 'liability_asset_selector.dart';
import 'liability_pill_toggle.dart';
import 'liability_repayment_method_section.dart';

class LiabilityForm extends StatelessWidget {
  const LiabilityForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Pre-registered by TransactionController.onInit()
    final controller = Get.find<LiabilityFormController>();
    final accentColor = _accentColor(context, controller);

    return Column(
      children: [
        Expanded(
          child: _buildScrollableContent(context, controller, accentColor),
        ),
        Obx(() {
          if (!controller.showKeypad.value) return const SizedBox.shrink();
          return _buildMoneyKeypadPanel(context, controller, accentColor);
        }),
      ],
    );
  }

  Color _accentColor(BuildContext context, LiabilityFormController controller) {
    // Use controller.direction directly if it's constant for this controller
    final isBorrowSide = controller.direction == LiabilityDirection.borrow;
    return isBorrowSide
        ? context.ccColorScheme.debtLoan
        : context.ccColorScheme.debtLoanSecondary;
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
        Obx(() {
          final bool isInitiate =
              controller.action.value == LiabilityAction.initiate;
          return LiabilityPillToggle(
            selectedIndex: isInitiate ? 0 : 1,
            firstLabel: el.tr(
              CcLocaleKeys.transaction_liability_direction_borrow,
            ),
            secondLabel: el.tr(CcLocaleKeys.transaction_record_repay),
            activeColor: accentColor,
            onChanged: (index) => controller.setAction(
              index == 0 ? LiabilityAction.initiate : LiabilityAction.settle,
            ),
          );
        }),
        const CcSpaceSM(),
        LiabilityAssetSelector(
          controller: controller,
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
                if (controller.action.value != LiabilityAction.initiate) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    LiabilityRepaymentMethodSection(
                      controller: controller,
                      accentColor: accentColor,
                    ),
                    const CcSpaceSM(),
                  ],
                );
              }),
              Obx(
                () => TransactionAdditionalDetailsSection(
                  isExpanded: controller.showMoreDetails.value,
                  onToggle: controller.toggleMoreDetails,
                  selectedDate: controller.date.value,
                  onDateSelected: controller.setDate,
                  onCalendarTap: () => controller.pickDate(context),
                  noteController: controller.noteController,
                  hasNoteText: controller.hasNoteText.value,
                  activeColor: accentColor,
                  hideDate: true,
                ),
              ),
              const CcSpaceSM(),
              _buildSubmitButton(context, controller, accentColor),
              const CcSpaceXS(),
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
      final bool isInitiate =
          controller.action.value == LiabilityAction.initiate;

      final label = !isInitiate
          ? el.tr(CcLocaleKeys.transaction_amount)
          : el.tr(CcLocaleKeys.transaction_liability_amount_borrow_label);

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
      final bool isInitiate =
          controller.action.value == LiabilityAction.initiate;

      final label = isInitiate
          ? el.tr(
              CcLocaleKeys.transaction_liability_wallet_borrow_label,
            ) // Receiving wallet
          : el.tr(CcLocaleKeys.transaction_source_debt); // Repayment source

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

  Widget _buildSubmitButton(
    BuildContext context,
    LiabilityFormController controller,
    Color accentColor,
  ) {
    return Obx(() {
      final bool isInitiate =
          controller.action.value == LiabilityAction.initiate;
      final text = isInitiate
          ? el.tr(CcLocaleKeys.transaction_record_liability)
          : el.tr(CcLocaleKeys.transaction_record_repay);

      return TransactionSubmitButton(
        text: text,
        isSubmitting: controller.isSubmitting.value,
        isEnabled: controller.canSubmit,
        onTap: () => controller.submitForm(context),
        activeColor: accentColor,
        leadingIcon: isInitiate ? Icons.call_received : Icons.call_made,
        leadingIconSize: 18,
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
