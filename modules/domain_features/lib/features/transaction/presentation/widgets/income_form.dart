import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../wallet/presentation/widgets/cc_wallet_strip_card.dart';
import '../get_x/income_form_controller.dart';
import 'category_selection_section.dart';
import 'cc_amount_input_section.dart';
import 'cc_form_label.dart';
import 'money_keypad_panel.dart';
import 'transaction_additional_details_section.dart';
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
    IncomeFormController controller,
    Color accentColor,
  ) {
    return CategorySelectionSection(
      key: ValueKey(controller.categoryKey.value),
      type: CategoryType.income,
      activeColor: accentColor,
      autoSelectFirst: !controller.isEditing,
      initialSelectedCategoryId: controller.editingTransaction?.categoryId,
      onCategorySelected: controller.setCategory,
    );
  }

  Widget _buildFormFields(
    BuildContext context,
    IncomeFormController controller,
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
              text: el.tr(CcLocaleKeys.transaction_record_income),
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
    IncomeFormController controller,
    Color accentColor,
  ) {
    return SafeArea(
      top: false,
      child: MoneyKeypadPanel(
        onKeyPress: controller.handleKeyPress,
        onDelete: controller.handleDelete,
        onClear: () => controller.amountStr.value = '0',
        suggestions: controller.quickAmounts,
        onSuggestion: (value) => controller.amountStr.value = value.toString(),
        onDone: controller.hideKeypad,
        activeColor: accentColor,
      ),
    );
  }
}
