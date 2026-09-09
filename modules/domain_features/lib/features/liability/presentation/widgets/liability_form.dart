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
import '../../../wallet/presentation/widgets/wallet_strip_card.dart';
import '../get_x/liability_base_form_controller.dart';
import '../get_x/liability_form_controller.dart';
import 'liability_action_toggle.dart';
import 'liability_asset_selector.dart';
import 'liability_repayment_method_section.dart';

class LiabilityForm extends StatelessWidget {
  const LiabilityForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Pre-registered by TransactionController.onInit()
    final controller = Get.find<LiabilityFormController>();

    return Obx(() {
      final isIncrease =
          controller.action.value == LiabilityFormAction.increase;
      final accentColor = isIncrease
          ? context.ccColorScheme.liability
          : context.ccColorScheme.liabilitySecondary;

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
          children: [
            LiabilityActionToggle(
              value: controller.action.value,
              direction: controller.direction,
              activeColor: accentColor,
              onChanged: controller.setAction,
            ),
            const CcSpaceSM(),
            _buildInitiateSection(context, controller, accentColor),
          ],
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
                final liability = controller.mergedItems
                    .firstWhereOrNull(
                      (b) =>
                          b.liability.id ==
                          controller.selectedLiabilityId.value,
                    )
                    ?.liability;

                // Only show repayment plan for new/uninitialized liabilities.
                // For existing liabilities, we are just borrowing more.
                if (liability == null ||
                    liability.principalAmount > 0 ||
                    controller.action.value == LiabilityFormAction.decrease) {
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
              TransactionAdditionalDetailsSection(
                isExpanded: controller.showMoreDetails.value,
                onToggle: controller.toggleMoreDetails,
                selectedDate: controller.date.value,
                onDateSelected: controller.setDate,
                onCalendarTap: () => controller.pickDate(context),
                noteController: controller.noteController,
                activeColor: accentColor,
                hideDate: true,
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
    final liability = controller.mergedItems
        .firstWhereOrNull(
          (b) => b.liability.id == controller.selectedLiabilityId.value,
        )
        ?.liability;

    final isRepay = controller.action.value == LiabilityFormAction.decrease;

    final label =
        (isRepay || (liability != null && liability.principalAmount > 0))
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
      onCopy: () => CcStringHelper.copyToClipboard(controller.amountStr.value),
    );
  }

  Widget _buildWalletSection(
    BuildContext context,
    LiabilityFormController controller,
    Color accentColor,
  ) {
    final isRepay = controller.action.value == LiabilityFormAction.decrease;
    final text = isRepay
        ? el.tr(CcLocaleKeys.transaction_source_debt)
        : el.tr(CcLocaleKeys.transaction_liability_wallet_borrow_label);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: text),
        const CcSpaceXS(),
        Obx(
          () => WalletStripCard(
            wallets: controller.wallets.toList(),
            selectedWalletId: controller.selectedWalletId.value,
            activeColor: accentColor,
            defaultBgColor: context.verticalGradient(accentColor),
            onWalletSelected: controller.setWalletId,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    LiabilityFormController controller,
    Color accentColor,
  ) {
    final isRepay = controller.action.value == LiabilityFormAction.decrease;
    final liability = controller.mergedItems
        .firstWhereOrNull(
          (b) => b.liability.id == controller.selectedLiabilityId.value,
        )
        ?.liability;

    final String text;
    final IconData icon;

    if (isRepay) {
      text = el.tr(CcLocaleKeys.transaction_record_repay);
      icon = Icons.arrow_circle_down;
    } else {
      text = (liability != null && liability.principalAmount > 0)
          ? el.tr(CcLocaleKeys.transaction_record_liability) // Borrow more
          : el.tr(CcLocaleKeys.transaction_record_liability); // Initiate
      icon = Icons.arrow_circle_up;
    }

    return TransactionSubmitButton(
      text: text,
      isSubmitting: controller.isSubmitting.value,
      isEnabled: controller.canSubmit,
      onTap: () => controller.submitForm(context),
      activeColor: accentColor,
      leadingIcon: icon,
      leadingIconSize: 18,
    );
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
