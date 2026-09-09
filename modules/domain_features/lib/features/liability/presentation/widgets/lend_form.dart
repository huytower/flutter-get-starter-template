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
import '../get_x/lend_form_controller.dart';
import '../get_x/liability_base_form_controller.dart';
import 'liability_action_toggle.dart';
import 'liability_asset_selector.dart';

class LendForm extends StatelessWidget {
  const LendForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Pre-registered by TransactionController.onInit()
    final controller = Get.find<LendFormController>();

    return Obx(() {
      final isIncrease =
          controller.action.value == LiabilityFormAction.increase;
      final accentColor = isIncrease
          ? context.ccColorScheme.liability
          : context.ccColorScheme.liabilitySecondary;

      return Column(
        children: [
          Expanded(
            child: GestureDetector(
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
            ),
          ),
          if (controller.showKeypad.value)
            _buildMoneyKeypadPanel(context, controller, accentColor),
        ],
      );
    });
  }

  Widget _buildInitiateSection(
    BuildContext context,
    LendFormController controller,
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
    LendFormController controller,
    Color accentColor,
  ) {
    final liability = controller.mergedItems
        .firstWhereOrNull(
          (b) => b.liability.id == controller.selectedLiabilityId.value,
        )
        ?.liability;

    final isCollect = controller.action.value == LiabilityFormAction.decrease;

    final label =
        (isCollect || (liability != null && liability.principalAmount > 0))
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
      onCopy: () => CcStringHelper.copyToClipboard(controller.amountStr.value),
    );
  }

  Widget _buildWalletSection(
    BuildContext context,
    LendFormController controller,
    Color accentColor,
  ) {
    final isCollect = controller.action.value == LiabilityFormAction.decrease;
    final text = isCollect
        ? el.tr(CcLocaleKeys.transaction_source_debt)
        : el.tr(CcLocaleKeys.transaction_liability_wallet_lend_label);

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
    LendFormController controller,
    Color accentColor,
  ) {
    final isCollect = controller.action.value == LiabilityFormAction.decrease;
    final liability = controller.mergedItems
        .firstWhereOrNull(
          (b) => b.liability.id == controller.selectedLiabilityId.value,
        )
        ?.liability;

    final String text;
    final IconData icon;

    if (isCollect) {
      text = el.tr(CcLocaleKeys.transaction_record_collect);
      icon = Icons.arrow_circle_up;
    } else {
      text = (liability != null && liability.principalAmount > 0)
          ? el.tr(CcLocaleKeys.transaction_record_liability) // Lend more
          : el.tr(CcLocaleKeys.transaction_liability_direction_lend);
      icon = Icons.arrow_circle_down;
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
