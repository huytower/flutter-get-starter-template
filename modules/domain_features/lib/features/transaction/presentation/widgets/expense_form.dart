import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/presentation/widgets/entry_additional_details_section.dart';
import 'package:domain_features/core/presentation/widgets/entry_form_container.dart';
import 'package:domain_features/core/presentation/widgets/entry_form_two_column.dart';
import 'package:domain_features/core/presentation/widgets/entry_submit_button.dart';
import 'package:domain_features/export_domain_features.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';
import 'package:theme/export_theme.dart';

import '../get_x/expense_form_controller.dart';
import 'expense_category_selection_section.dart';
import 'form_amount_section.dart';
import 'form_keypad_panel.dart';
import 'form_wallet_section.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key, this.tag});

  final String? tag;

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  late final ExpenseFormController controller;
  final GlobalKey _amountFieldKey = GlobalKey();

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
  }

  @override
  Widget build(BuildContext context) {
    final guideline = getIt<GuidelineProvider>();

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
    GuidelineProvider guideline,
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
        child: EntryFormTwoColumn.shouldUse(context)
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
    GuidelineProvider guideline,
    Color accentColor,
  ) {
    return Obx(
      () => EntryFormTwoColumn(
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
      return EntryAdditionalDetailsSection(
        isExpanded: true,
        selectedDate: controller.date.value,
        onDateSelected: controller.setDate,
        onCalendarTap: () => controller.pickDate(context),
        noteController: controller.noteController,
        activeColor: accentColor,
        hideDate: true,
      );
    }
    return EntryAdditionalDetailsSection(
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
    GuidelineProvider guideline,
    Color accentColor,
  ) {
    return EntrySubmitButton(
      text: controller.isEditing
          ? el.tr(PrjLocaleKeys.common_save)
          : el.tr(PrjLocaleKeys.transaction_record_expense),
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
    GuidelineProvider guideline,
    Color accentColor,
  ) {
    return EntryFormContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountSection(context, controller, accentColor),
          const CcSpaceSM(),
          if (!controller.isEditing) ...[
            _buildWalletSection(context, controller, accentColor),
            const CcSpaceSM(),
          ],
          _buildDetailsSection(context, controller, accentColor),
          const CcSpaceSM(),
          _buildSubmitButton(context, controller, guideline, accentColor),
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
    return FormAmountSection(
      controller: controller,
      label: el.tr(PrjLocaleKeys.transaction_amount),
      activeColor: accentColor,
      fieldKey: _amountFieldKey,
    );
  }

  Widget _buildWalletSection(
    BuildContext context,
    ExpenseFormController controller,
    Color accentColor,
  ) {
    return FormWalletSection(
      controller: controller,
      label: el.tr(PrjLocaleKeys.transaction_source_expense),
      activeColor: accentColor,
    );
  }

  Widget _buildMoneyKeypadPanel(
    BuildContext context,
    ExpenseFormController controller,
    Color accentColor,
  ) {
    return FormKeypadPanel(controller: controller, activeColor: accentColor);
  }
}
