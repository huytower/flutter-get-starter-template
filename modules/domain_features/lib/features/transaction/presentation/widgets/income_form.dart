import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../wallet/presentation/widgets/wallet_strip_card.dart';
import '../get_x/income_form_controller.dart';
import 'category_selection_section.dart';
import 'cc_amount_input_section.dart';
import 'money_keypad_panel.dart';
import 'transaction_additional_details_section.dart';
import 'transaction_form_container.dart';
import 'transaction_submit_button.dart';

class IncomeForm extends StatelessWidget {
  const IncomeForm({super.key, this.tag});

  /// GetX tag for the underlying [IncomeFormController] instance. Leave null
  /// for the persistent entry-tab form; pass a distinct tag (e.g. from
  /// [EditTransactionSheet]) to get an isolated instance so editing an old
  /// transaction never touches the entry tab's in-progress draft.
  final String? tag;

  @override
  Widget build(BuildContext context) {
    // See ExpenseForm.build() for why untagged vs. tagged resolve
    // differently: the untagged instance is pre-registered by
    // TransactionController.onInit(), the tagged edit-mode instance isn't.
    final controller = tag == null
        ? Get.find<IncomeFormController>()
        : Get.put(getIt<IncomeFormController>(), tag: tag);
    final guideline = Get.find<GuidelineController>();

    const accentColor = PrjColors.success;

    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: controller.isEditing ? FlexFit.loose : FlexFit.tight,
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
    IncomeFormController controller,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySection(controller, accentColor),
            const CcSpaceSM(),
            _buildFormFields(context, controller, guideline, accentColor),
          ],
        ),
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
      autoSelectFirst: !controller.isEditing,
      // pendingPrefillCategoryId must win over editingTransaction?.categoryId:
      // categoryId is a non-nullable String, so while editing it would always
      // short-circuit the `??` chain and silently discard a just-applied
      // quick-entry suggestion's category.
      initialSelectedCategoryId:
          controller.pendingPrefillCategoryId.value ??
          controller.selectedCategory.value?.id ??
          controller.editingTransaction?.categoryId,
      onCategorySelected: controller.setCategory,
    );
  }

  Widget _buildFormFields(
    BuildContext context,
    IncomeFormController controller,
    GuidelineController guideline,
    Color accentColor,
  ) {
    return TransactionFormContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountSection(context, controller, accentColor),
          if (!controller.isEditing) ...[
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
              hasNoteText: controller.hasNoteText.value,
              activeColor: accentColor,
            ),
          ],
          if (controller.isEditing) ...[
            const CcSpaceSM(),
            TransactionAdditionalDetailsSection(
              isExpanded: true,
              selectedDate: controller.date.value,
              onDateSelected: controller.setDate,
              onCalendarTap: () => controller.pickDate(context),
              noteController: controller.noteController,
              hasNoteText: controller.hasNoteText.value,
              activeColor: accentColor,
              hideDate: true,
            ),
          ],
          const CcSpaceSM(),
          TransactionSubmitButton(
            text: controller.isEditing
                ? el.tr(CcLocaleKeys.common_save)
                : el.tr(CcLocaleKeys.transaction_record_income),
            isSubmitting: controller.isSubmitting.value,
            isEnabled: controller.canSubmit,
            onTap: () => controller.submitForm(context),
            activeColor: accentColor,
            leadingIcon: Icons.arrow_downward,
            leadingIconSize: 18,
            badge: guideline.isTaskActive('first_transaction')
                ? CcGuidelineBadge(
                    size: 8,
                    color: guideline.currentColor,
                    bounceTrigger: guideline.bounceTrigger,
                  )
                : null,
          ),
          const CcSpaceXS(),
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
      onClear: () => controller.amountStr.value = '0',
      onCopy: () => CcStringHelper.copyToClipboard(controller.amountStr.value),
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
        WalletStripCard(
          wallets: controller.wallets,
          selectedWalletId: controller.selectedWalletId.value,
          activeColor: accentColor,
          defaultBgColor: context.verticalGradient(accentColor),
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
    return MoneyKeypadPanel(
      onKeyPress: controller.handleKeyPress,
      onDelete: controller.handleDelete,
      onClear: () => controller.amountStr.value = '0',
      suggestions: controller.quickAmounts,
      onSuggestion: (value) => controller.amountStr.value = value.toString(),
      onDone: controller.hideKeypad,
      activeColor: accentColor,
    );
  }
}
