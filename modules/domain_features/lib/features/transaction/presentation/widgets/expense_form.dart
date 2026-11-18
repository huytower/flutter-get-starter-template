import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/export_domain_features.dart';
import 'package:domain_features/features/transaction/presentation/widgets/transaction_additional_details_section.dart';
import 'package:domain_features/features/transaction/presentation/widgets/transaction_form_container.dart';
import 'package:domain_features/features/transaction/presentation/widgets/transaction_submit_button.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';
import 'package:theme/export_theme.dart';

import '../get_x/expense_form_controller.dart';
import 'cc_amount_input_section.dart';
import 'expense_category_selection_section.dart';
import 'money_keypad_panel.dart';
import 'transaction_form_two_column.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key, this.tag});

  final String? tag;

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  late final ExpenseFormController controller;
  final GlobalKey _amountFieldKey = GlobalKey();
  Worker? _tabRevisitWorker;

  @override
  void initState() {
    super.initState();
    controller = widget.tag == null
        ? Get.find<ExpenseFormController>()
        : (Get.isRegistered<ExpenseFormController>(tag: widget.tag)
              ? Get.find<ExpenseFormController>(tag: widget.tag)
              : Get.put(getIt<ExpenseFormController>(), tag: widget.tag));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.loadSuggestions();
      controller.refreshTimeBasedSuggestion();
      if (widget.tag == null) controller.refreshLocationSuggestion();
    });

    if (Get.isRegistered<TransactionController>()) {
      final transactionController = Get.find<TransactionController>();
      _tabRevisitWorker = ever(transactionController.selectedTabIndex, (
        int index,
      ) {
        if (!mounted) return;
        final tabs = transactionController.visibleTabs;
        final isExpenseActive =
            index >= 0 &&
            index < tabs.length &&
            tabs[index] == TransactionTabKind.expense;
        if (isExpenseActive) {
          controller.loadSuggestions();
          controller.refreshTimeBasedSuggestion();
          if (widget.tag == null) controller.refreshLocationSuggestion();
          controller.restoreActiveTabSuggestions();
        } else {
          controller.hideSuggestionsWhileInactive();
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

    final accentColor = context.expenseAccent;

    return Column(
      children: [
        Expanded(
          child: _buildScrollableContent(
            context,
            controller,
            guideline,
            accentColor,
          ),
        ),
        Obx(
          () => controller.showKeypad.value
              ? _buildMoneyKeypadPanel(context, controller, accentColor)
              : const SizedBox.shrink(),
        ),
      ],
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
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: TransactionFormTwoColumn.shouldUse(context)
            ? _buildTwoColumnContent(
                context,
                controller,
                guideline,
                accentColor,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpenseCategorySelectionSection(
                    controller: controller,
                    activeColor: accentColor,
                  ),
                  const CcSpaceSM(),
                  Obx(
                    () => _buildFormFields(
                      context,
                      controller,
                      guideline,
                      accentColor,
                    ),
                  ),
                  const CcSpaceMD(),
                ],
              ),
      ),
    );
  }

  /// Left: category + date/note details. Right: amount, source of expense
  /// and the submit button.
  Widget _buildTwoColumnContent(
    BuildContext context,
    ExpenseFormController controller,
    GuidelineController guideline,
    Color accentColor,
  ) {
    return Obx(
      () => TransactionFormTwoColumn(
        leading: [
          ExpenseCategorySelectionSection(
            controller: controller,
            activeColor: accentColor,
          ),
        ],
        details: _buildDetailsSection(
          context,
          controller,
          accentColor,
          alwaysExpanded: true,
        ),
        right: [
          _buildAmountSection(context, controller, accentColor),
          if (!controller.isEditing) ...[
            const CcSpaceSM(),
            _buildWalletSection(context, controller, accentColor),
          ],
          const CcSpaceSM(),
          _buildSubmitButton(context, controller, guideline, accentColor),
          const CcSpaceXS(),
        ],
      ),
    );
  }

  /// Date + note. In the two-column layout it is always open (there is room
  /// for it); in the single column it keeps its "More details" toggle.
  Widget _buildDetailsSection(
    BuildContext context,
    ExpenseFormController controller,
    Color accentColor, {
    bool alwaysExpanded = false,
  }) {
    if (controller.isEditing) {
      return TransactionAdditionalDetailsSection(
        isExpanded: true,
        selectedDate: controller.date.value,
        onDateSelected: controller.setDate,
        onCalendarTap: () => controller.pickDate(context),
        noteController: controller.noteController,
        activeColor: accentColor,
        hideDate: true,
      );
    }
    return TransactionAdditionalDetailsSection(
      isExpanded: alwaysExpanded || controller.showMoreDetails.value,
      onToggle: alwaysExpanded ? null : controller.toggleMoreDetails,
      selectedDate: controller.date.value,
      onDateSelected: controller.setDate,
      onCalendarTap: () => controller.pickDate(context),
      noteController: controller.noteController,
      activeColor: accentColor,
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    ExpenseFormController controller,
    GuidelineController guideline,
    Color accentColor,
  ) {
    return TransactionSubmitButton(
      text: controller.isEditing
          ? el.tr(CcLocaleKeys.common_save)
          : el.tr(CcLocaleKeys.transaction_record_expense),
      isSubmitting: controller.isSubmitting.value,
      isEnabled: controller.canSubmit,
      onTap: () => controller.submitForm(context),
      activeColor: accentColor,
      leadingIcon: Icons.arrow_circle_down,
      leadingIconSize: 28,
      badge: guideline.isTaskActive('first_transaction')
          ? PrjGuidelineBadge(
              size: context.respDim(6),
              label: guideline.bannerDescription,
              labelAbove: true,
              growRight: false,
            )
          : null,
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
            leadingIconSize: 28,
            badge: guideline.isTaskActive('first_transaction')
                ? PrjGuidelineBadge(
                    size: context.respDim(6),
                    label: guideline.bannerDescription,
                    labelAbove: true,
                    growRight: false,
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
    return Obx(
      () => CcAmountInputSection(
        label: el.tr(CcLocaleKeys.transaction_amount),
        amountStr: controller.amountStr.value,
        quickAmounts: controller.quickAmounts,
        isKeypadVisible: controller.showKeypad.value,
        activeColor: accentColor,
        currencyCode: controller.currencyCode.value,
        fieldKey: _amountFieldKey,
        onTap: () =>
            controller.showKeypadAndScroll(context, fieldKey: _amountFieldKey),
        onQuickAmountSelected: (amount) =>
            controller.amountStr.value = amount.toString(),
        onClear: () => controller.amountStr.value = '0',
        onCopy: () =>
            CcStringHelper.copyToClipboard(controller.amountStr.value),
      ),
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
      suggestions: controller.quickAmounts,
      onSuggestion: (value) => controller.amountStr.value = value.toString(),
      onDone: controller.hideKeypad,
      activeColor: accentColor,
    );
  }
}
