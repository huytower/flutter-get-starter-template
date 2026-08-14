import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/transaction/presentation/widgets/transaction_additional_details_section.dart';
import 'package:domain_features/features/transaction/presentation/widgets/transaction_submit_button.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../wallet/presentation/widgets/cc_wallet_strip_card.dart';
import '../get_x/expense_form_controller.dart';
import 'category_selection_section.dart';
import 'cc_amount_input_section.dart';
import 'cc_form_label.dart';
import 'money_keypad_panel.dart';

class ExpenseForm extends StatelessWidget {
  const ExpenseForm({super.key, this.tag});

  /// GetX tag for the underlying [ExpenseFormController] instance. Leave
  /// null for the persistent entry-tab form; pass a distinct tag (e.g. from
  /// [EditTransactionSheet]) to get an isolated instance so editing an old
  /// transaction never touches the entry tab's in-progress draft.
  final String? tag;

  @override
  Widget build(BuildContext context) {
    // The untagged (entry-tab) instance is registered early by
    // TransactionController.onInit(), so it's always already findable here —
    // Get.put-ing it directly in build() previously caused a "setState
    // during build" bug. Edit-mode's tagged instance is never pre-registered
    // (only TransactionController's own default tag is), so it still needs
    // an on-demand Get.put here.
    final controller = tag == null
        ? Get.find<ExpenseFormController>()
        : Get.put(getIt<ExpenseFormController>(), tag: tag);
    final guideline = Get.find<GuidelineController>();

    final accentColor = context.ccColorScheme.error;

    return Obx(
      () => Column(
        children: [
          Expanded(
            child: _buildScrollableContent(
              context,
              controller,
              guideline,
              accentColor,
            ),
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
    GuidelineController guideline,
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
            _buildFormFields(context, controller, guideline, accentColor),
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
      autoSelectFirst: !controller.isEditing,
      initialSelectedCategoryId: controller.editingTransaction?.categoryId,
      onCategorySelected: controller.setCategory,
    );
  }

  Widget _buildFormFields(
    BuildContext context,
    ExpenseFormController controller,
    GuidelineController guideline,
    Color accentColor,
  ) {
    final scheme = context.ccColorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: context.brLg,
        border: Border.all(
          color: scheme.onSurface.withOpacity(0.08),
          width: context.respDim(1),
        ),
      ),
      child: CcPadding(
        Column(
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
              badge: guideline.isTaskActive('first_transaction')
                  ? CcGuidelineBadge(
                      size: 8,
                      color: guideline.currentColor,
                      bounceTrigger: guideline.bounceTrigger,
                    )
                  : null,
            ),
            const CcSpaceLG(),
          ],
        ),
        6,
        12,
        12,
        6,
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
