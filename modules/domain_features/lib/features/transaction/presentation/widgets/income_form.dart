import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/presentation/widgets/entry_additional_details_section.dart';
import 'package:domain_features/core/presentation/widgets/entry_form_container.dart';
import 'package:domain_features/core/presentation/widgets/entry_form_two_column.dart';
import 'package:domain_features/core/presentation/widgets/entry_submit_button.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../guideline/export_guideline.dart';
import '../get_x/income_form_controller.dart';
import 'form_amount_section.dart';
import 'form_keypad_panel.dart';
import 'form_wallet_section.dart';
import 'income_category_selection_section.dart';

class IncomeForm extends StatefulWidget {
  const IncomeForm({super.key, this.tag});

  /// GetX tag for the underlying [IncomeFormController] instance. Leave null
  /// for the persistent entry-tab form; pass a distinct tag (e.g. from
  /// [EditTransactionSheet]) to get an isolated instance so editing an old
  /// transaction never touches the entry tab's in-progress draft.
  final String? tag;

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  late final IncomeFormController controller;
  final GlobalKey _amountFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = widget.tag == null
        ? Get.find<IncomeFormController>()
        : (Get.isRegistered<IncomeFormController>(tag: widget.tag)
              ? Get.find<IncomeFormController>(tag: widget.tag)
              : Get.put(getIt<IncomeFormController>(), tag: widget.tag));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.loadSuggestions();
      if (widget.tag == null) controller.refreshMonthlySuggestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    // See ExpenseForm.build() for why untagged vs. tagged resolve
    // differently: the untagged instance is pre-registered by
    // TransactionController.onInit(), the tagged edit-mode instance isn't.
    final guideline = getIt<GuidelineProvider>();

    final accentColor = context.incomeAccent;

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
                  IncomeCategorySelectionSection(
                    controller: controller,
                    activeColor: accentColor,
                  ),
                  const CcSpaceSM(),
                  _buildFormFields(context, controller, guideline, accentColor),
                  const CcSpaceMD(),
                ],
              ),
      ),
    );
  }

  /// Landscape tablet: category + date/note on the left; amount, source of
  /// income and submit on the right.
  Widget _buildTwoColumnContent(
    BuildContext context,
    IncomeFormController controller,
    GuidelineProvider guideline,
    Color accentColor,
  ) {
    return EntryFormTwoColumn(
      leading: [
        IncomeCategorySelectionSection(
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
        if (!controller.hasEditing) ...[
          const CcSpaceSM(),
          _buildWalletSection(context, controller, accentColor),
        ],
        const CcSpaceSM(),
        _buildSubmitButton(context, controller, guideline, accentColor),
        const CcSpaceXS(),
      ],
    );
  }

  /// Date + note. In the two-column layout it is always open (there is room
  /// for it); in the single column it keeps its "More details" toggle.
  Widget _buildDetailsSection(
    BuildContext context,
    IncomeFormController controller,
    Color accentColor, {
    bool alwaysExpanded = false,
  }) {
    if (controller.hasEditing) {
      return EntryAdditionalDetailsSection(
        hasExpanded: true,
        selectedDate: controller.date.value,
        onDateSelected: controller.setDate,
        onCalendarTap: () => controller.pickDate(context),
        noteController: controller.noteController,
        activeColor: accentColor,
        hideDate: true,
      );
    }
    return EntryAdditionalDetailsSection(
      hasExpanded: alwaysExpanded || controller.showMoreDetails.value,
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
    IncomeFormController controller,
    GuidelineProvider guideline,
    Color accentColor,
  ) {
    return EntrySubmitButton(
      text: controller.hasEditing
          ? el.tr(PrjLocaleKeys.common_save)
          : el.tr(PrjLocaleKeys.transaction_record_income),
      hasSubmitting: controller.hasSubmitting.value,
      hasEnabled: controller.canSubmit,
      onTap: () => controller.submitForm(context),
      activeColor: accentColor,
      leadingIcon: Icons.arrow_circle_up,
      leadingIconSize: 18,
      badge: guideline.isTaskActive('first_transaction')
          ? PrjGuidelineBadge(
              size: context.respDim(8),
              label: guideline.bannerDescription,
              growRight: false,
            )
          : null,
    );
  }

  Widget _buildFormFields(
    BuildContext context,
    IncomeFormController controller,
    GuidelineProvider guideline,
    Color accentColor,
  ) {
    return EntryFormContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountSection(context, controller, accentColor),
          const CcSpaceSM(),
          if (!controller.hasEditing) ...[
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
    IncomeFormController controller,
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
    IncomeFormController controller,
    Color accentColor,
  ) {
    return FormWalletSection(
      controller: controller,
      label: el.tr(PrjLocaleKeys.transaction_source_income),
      activeColor: accentColor,
    );
  }

  Widget _buildMoneyKeypadPanel(
    BuildContext context,
    IncomeFormController controller,
    Color accentColor,
  ) {
    return FormKeypadPanel(controller: controller, activeColor: accentColor);
  }
}
