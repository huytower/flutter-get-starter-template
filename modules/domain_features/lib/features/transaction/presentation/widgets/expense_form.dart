import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../domain/entities/transaction_entity.dart';
import '../get_x/expense_form_controller.dart';
import 'category_selection_section.dart';
import 'cc_amount_input_section.dart';
import 'cc_form_label.dart';
import 'money_keypad_panel.dart';
import 'quick_entry_section.dart';
import 'receipt_source_sheet.dart';
import 'transaction_additional_details_section.dart';
import 'transaction_submit_button.dart';
import 'transaction_wallet_selector.dart';

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
    controller.refreshLocationSuggestion();
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
    final suggestionLabel = _suggestionLabel(controller);
    final canUseAiSmartEntry =
        getIt<UserLevelController>().status.value.canUseAiSmartEntry;

    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_SM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canUseAiSmartEntry)
            _buildQuickEntrySection(context, controller, accentColor),
          if (suggestionLabel != null) ...[
            CcSuggestionChip(
              label: suggestionLabel,
              accentColor: accentColor,
              icon: controller.merchantMatchSuggestion.value != null
                  ? Icons.auto_awesome
                  : Icons.place,
              onTap: () => _applySuggestion(controller),
              onDismiss: () => _dismissSuggestion(controller),
            ),
            const CcSpaceLG(),
          ],
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
    );
  }

  Widget _buildQuickEntrySection(
    BuildContext context,
    ExpenseFormController controller,
    Color accentColor,
  ) {
    final suggestion = controller.quickEntrySuggestion.value;
    final errorKey = controller.quickEntryErrorKey.value;
    return QuickEntrySection(
      controller: controller.quickEntryController,
      isParsing: controller.isParsingQuickEntry.value,
      isListening: controller.isListeningQuickEntry.value,
      suggestionLabel: suggestion != null
          ? controller.quickEntryResultLabel(suggestion)
          : null,
      errorText: errorKey != null ? el.tr(errorKey) : null,
      activeColor: accentColor,
      onSubmitted: (_) => controller.submitQuickEntry(),
      onMicTap: controller.toggleVoiceQuickEntry,
      onScanTap: () => _pickReceiptSource(context, controller),
      onApplySuggestion: () {
        if (suggestion != null) controller.applyQuickEntryParse(suggestion);
      },
      onDismissSuggestion: controller.dismissQuickEntrySuggestion,
    );
  }

  Future<void> _pickReceiptSource(
    BuildContext context,
    ExpenseFormController controller,
  ) async {
    // Takes the quick-entry lock before the sheet even opens (not after it
    // resolves) so the text/voice path can't run concurrently with this one
    // during the sheet interaction — see beginQuickEntryImage's doc.
    if (!controller.beginQuickEntryImage()) return;
    final fromCamera = await ReceiptSourceSheet.show(context);
    if (fromCamera == null) {
      controller.cancelQuickEntryImage();
      return;
    }
    controller.submitQuickEntryFromImage(fromCamera: fromCamera);
  }

  /// AI Smart Entry suggestion row — Phase 3.3 note-based merchant match
  /// takes priority over Phase 3.5 location match (a note is a more specific
  /// signal than "you're near a place you've spent before"); only one is
  /// ever shown at a time.
  String? _suggestionLabel(ExpenseFormController controller) {
    final merchantMatch = controller.merchantMatchSuggestion.value;
    if (merchantMatch != null) {
      return el.tr(
        CcLocaleKeys.transaction_merchant_match_hint,
        namedArgs: {'label': _formatSuggestionLabel(merchantMatch)},
      );
    }
    final locationMatch = controller.locationMatchSuggestion.value;
    if (locationMatch != null) {
      return el.tr(
        CcLocaleKeys.transaction_location_match_hint,
        namedArgs: {'label': _formatSuggestionLabel(locationMatch)},
      );
    }
    return null;
  }

  String _formatSuggestionLabel(TransactionEntity match) =>
      '${match.category} · ${formatVndShort(match.amount)}đ';

  void _applySuggestion(ExpenseFormController controller) {
    final merchantMatch = controller.merchantMatchSuggestion.value;
    if (merchantMatch != null) {
      controller.applyMerchantMatch(merchantMatch);
      return;
    }
    final locationMatch = controller.locationMatchSuggestion.value;
    if (locationMatch != null) controller.applyLocationMatch(locationMatch);
  }

  void _dismissSuggestion(ExpenseFormController controller) {
    if (controller.merchantMatchSuggestion.value != null) {
      controller.dismissMerchantMatch();
    } else {
      controller.dismissLocationMatch();
    }
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
