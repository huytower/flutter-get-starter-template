import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../transaction_template/presentation/widgets/transaction_template_chip_list.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../get_x/expense_form_controller.dart';
import 'category_selection_section.dart';
import 'cc_amount_input_section.dart';
import 'cc_form_label.dart';
import 'money_keypad_panel.dart';
import 'transaction_additional_details_section.dart';
import 'transaction_submit_button.dart';
import 'transaction_wallet_selector.dart';

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
            _buildTemplateSection(context, controller, accentColor),
            _buildCategorySection(controller, accentColor),
            const CcSpaceLG(),
            _buildFormFields(context, controller, guideline, accentColor),
          ],
        ),
      ),
    );
  }

  /// LV3-gated "Quick templates" strip — same tier as Debt/Loan, see
  /// [UserLevelStatusEntity.canUseAiSmartEntry].
  Widget _buildTemplateSection(
    BuildContext context,
    ExpenseFormController controller,
    Color accentColor,
  ) {
    // UserLevelController is a plain getIt singleton (constructor-injected
    // into TransactionController elsewhere) — it's never `Get.put` into
    // GetX's own locator, so it must be read via getIt here, not
    // `Get.find`/`Get.isRegistered`. Its `status` Rx still drives this Obx
    // like any other reactive value regardless of how it was obtained.
    return Obx(() {
      final unlocked = getIt<UserLevelController>().status.value.canUseAiSmartEntry;
      if (!unlocked) return const SizedBox();

      return Padding(
        padding: EdgeInsets.only(bottom: context.respDim(16)),
        child: TransactionTemplateChipList(
          activeColor: accentColor,
          wallets: controller.wallets,
          onApply: controller.applyTemplate,
        ),
      );
    });
  }

  Widget _buildCategorySection(
    ExpenseFormController controller,
    Color accentColor,
  ) {
    return CategorySelectionSection(
      key: ValueKey(controller.categoryKey.value),
      activeColor: accentColor,
      autoSelectFirst: !controller.isEditing,
      initialSelectedCategoryId:
          controller.editingTransaction?.categoryId ??
          controller.pendingPrefillCategoryId.value ??
          controller.timeBasedSuggestedCategoryId,
      onCategorySelected: controller.setCategory,
    );
  }

  Widget _buildFormFields(
    BuildContext context,
    ExpenseFormController controller,
    GuidelineController guideline,
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
            merchantSuggestionLabel: _merchantSuggestionLabel(controller),
            onApplyMerchantSuggestion: () {
              final match = controller.merchantMatchSuggestion.value;
              if (match != null) controller.applyMerchantMatch(match);
            },
            onDismissMerchantSuggestion: controller.dismissMerchantMatch,
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
    );
  }

  /// Phase 3.3 "AI Autofill" — formats the fuzzy-matched past expense (if
  /// any) as "Cà phê · 30.000đ" for [TransactionAdditionalDetailsSection]'s
  /// suggestion row.
  String? _merchantSuggestionLabel(ExpenseFormController controller) {
    final match = controller.merchantMatchSuggestion.value;
    if (match == null) return null;
    return '${match.category} · ${formatVndShort(match.amount)}đ';
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
