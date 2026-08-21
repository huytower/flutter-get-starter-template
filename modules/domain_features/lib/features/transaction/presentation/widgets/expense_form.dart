import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/transaction/presentation/widgets/transaction_additional_details_section.dart';
import 'package:domain_features/features/transaction/presentation/widgets/transaction_submit_button.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../wallet/presentation/widgets/wallet_strip_card.dart';
import '../get_x/expense_form_controller.dart';
import 'category_selection_section.dart';
import 'cc_amount_input_section.dart';
import 'money_keypad_panel.dart';
import 'transaction_form_container.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key, this.tag});

  /// GetX tag for the underlying [ExpenseFormController] instance. Leave
  /// null for the persistent entry-tab form; pass a distinct tag (e.g. from
  /// [EditTransactionSheet]) to get an isolated instance so editing an old
  /// transaction never touches the entry tab's in-progress draft.
  final String? tag;

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  late final ExpenseFormController controller;

  @override
  void initState() {
    super.initState();
    // The untagged (entry-tab) instance is registered early by
    // TransactionController.onInit(), so it's always already findable here.
    // Edit-mode's tagged instance is never pre-registered (only
    // TransactionController's own default tag is), so it still needs an
    // on-demand Get.put here.
    controller = widget.tag == null
        ? Get.find<ExpenseFormController>()
        : Get.put(getIt<ExpenseFormController>(), tag: widget.tag);
    // Phase 3.5: this widget is rebuilt fresh every time the user returns to
    // the Transaction page (it's popped on bottom-nav navigation — see
    // TransactionPage), but the untagged controller is a persistent singleton
    // whose onInit only fires once ever — so this is the sole place that
    // refreshes the location suggestion on every screen-open (onInit
    // deliberately does not also call it; see ExpenseFormController.onInit).
    // Same reasoning applies to the Phase 3.2 time-based suggestion, which
    // also needs "now" re-evaluated on every revisit, not just once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.refreshTimeBasedSuggestion();
      controller.refreshLocationSuggestion();
    });
  }

  @override
  Widget build(BuildContext context) {
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
    ExpenseFormController controller,
    Color accentColor,
  ) {
    return CategorySelectionSection(
      key: ValueKey(controller.categoryKey.value),
      activeColor: accentColor,
      autoSelectFirst: !controller.isEditing,
      // pendingPrefillCategoryId must win over editingTransaction?.categoryId:
      // categoryId is a non-nullable String, so while editing it would always
      // short-circuit the `??` chain and silently discard a just-applied
      // merchant/location/quick-entry suggestion's category.
      initialSelectedCategoryId:
          controller.pendingPrefillCategoryId.value ??
          controller.selectedCategory.value?.id ??
          controller.editingTransaction?.categoryId ??
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
    return TransactionFormContainer(
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
            hasNoteText: controller.noteController.text.isNotEmpty,
            activeColor: accentColor,
          ),
          const CcSpaceSM(),
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
          const CcSpaceXS(),
        ],
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
      onClear: () => controller.amountStr.value = '0',
      onCopy: () => CcStringHelper.copyToClipboard(controller.amountStr.value),
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
