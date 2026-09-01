import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/budget_limit/export_budget_limit.dart';
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
import '../get_x/transaction_controller.dart';
import 'category_selection_section.dart';
import 'cc_amount_input_section.dart';
import 'money_keypad_panel.dart';
import 'transaction_form_container.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key, this.tag});

  final String? tag;

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  late final ExpenseFormController controller;
  Worker? _tabRevisitWorker;

  @override
  void initState() {
    super.initState();
    controller = widget.tag == null
        ? Get.find<ExpenseFormController>()
        : Get.put(getIt<ExpenseFormController>(), tag: widget.tag);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.refreshTimeBasedSuggestion();
      controller.refreshLocationSuggestion();
    });

    if (Get.isRegistered<TransactionController>()) {
      final transactionController = Get.find<TransactionController>();
      _tabRevisitWorker = ever(transactionController.selectedTabIndex, (
        int index,
      ) {
        if (!mounted) return;
        final tabs = transactionController.visibleTabs;
        if (index >= 0 &&
            index < tabs.length &&
            tabs[index] == TransactionTabKind.expense) {
          controller.refreshTimeBasedSuggestion();
          controller.refreshLocationSuggestion();
        }
      });
    }
  }

  @override
  void dispose() {
    _tabRevisitWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guideline = Get.find<GuidelineController>();

    final accentColor = context.ccColorScheme.error;

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
    if (!Get.isRegistered<BudgetLimitController>()) {
      Get.put(getIt<BudgetLimitController>());
    }

    return Obx(() {
      final categoryKey = controller.categoryKey.value;
      final pendingPrefill = controller.pendingPrefillCategoryId.value;

      return CategorySelectionSection(
        key: ValueKey(categoryKey),
        activeColor: accentColor,
        autoSelectFirst: !controller.isEditing,
        initialSelectedCategoryId:
            pendingPrefill ??
            controller.selectedCategory.value?.id ??
            controller.editingTransaction?.categoryId ??
            controller.timeBasedSuggestedCategoryId,
        onCategorySelected: controller.setCategory,
      );
    });
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
              activeColor: accentColor,
              hideDate: true,
            ),
          ],
          const CcSpaceSM(),
          TransactionSubmitButton(
            text: controller.isEditing
                ? el.tr(CcLocaleKeys.common_save)
                : el.tr(CcLocaleKeys.transaction_record_expense),
            isSubmitting: controller.isSubmitting.value,
            isEnabled: controller.canSubmit,
            onTap: () => controller.submitForm(context),
            activeColor: accentColor,
            leadingIcon: Icons.arrow_circle_down,
            leadingIconSize: 18,
            badge: guideline.isTaskActive('first_transaction')
                ? CcGuidelineBadge(
                    size: 8,
                    label: guideline.bannerDescription,
                    isDescriptionHidden: guideline.isDescriptionHidden.value,
                    onLabelTap: () =>
                        guideline.isDescriptionHidden.value = true,
                    color: guideline.currentColor,
                    bounceTrigger: guideline.bounceTrigger.value,
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
