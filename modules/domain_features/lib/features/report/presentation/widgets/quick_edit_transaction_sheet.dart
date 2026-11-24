import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/presentation/widgets/entry_form_container.dart';
import 'package:domain_features/core/presentation/widgets/entry_submit_button.dart';
import 'package:domain_features/core/presentation/widgets/money_keypad_panel.dart';
import 'package:domain_features/core/presentation/widgets/prj_amount_input_section.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../liability/presentation/widgets/borrow_asset_selector.dart';
import '../../../liability/presentation/widgets/lend_asset_selector.dart';
import '../../../transaction/presentation/widgets/category_selection_section.dart';
import '../../../transaction/presentation/widgets/investment_asset_selector.dart';
import '../get_x/quick_edit_transaction_sheet_controller.dart';

class QuickEditTransactionSheet
    extends GetView<QuickEditTransactionSheetController> {
  const QuickEditTransactionSheet({super.key});

  static Future<void> show(
    BuildContext context,
    TransactionEntity transaction,
  ) {
    final controller = Get.put(getIt<QuickEditTransactionSheetController>());
    controller.prepareForm(transaction, () {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    return CcAdaptiveBottomSheet.show<void>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const QuickEditTransactionSheet(),
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (Get.isRegistered<QuickEditTransactionSheetController>()) {
          Get.delete<QuickEditTransactionSheetController>();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final accentColor = controller.accentColor(context);

      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategorySelectionSection(context, accentColor),
                      const CcSpaceSM(),
                      _buildAmountSection(context, accentColor),
                      const CcSpaceSM(),
                      EntryFormContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_buildDateAndNoteSection(context)],
                        ),
                      ),
                      const CcSpaceSM(),
                      EntrySubmitButton(
                        text: el.tr(PrjLocaleKeys.common_save),
                        hasSubmitting: controller.hasSubmitting.value,
                        hasEnabled: true,
                        onTap: () => controller.save(context),
                        activeColor: accentColor,
                      ),
                      const CcSpaceXS(),
                    ],
                  ),
                ),
              ),
              if (controller.showKeypad.value)
                MoneyKeypadPanel(
                  onKeyPress: controller.handleKeyPress,
                  onDelete: controller.handleDelete,
                  onClear: controller.onClearAmount,
                  suggestions: MoneyConstants.getQuickAmounts(
                    currencyCode: controller.currencyCode,
                  ),
                  onSuggestion: (value) =>
                      controller.amountStr.value = value.toString(),
                  onDone: controller.hideKeypad,
                  activeColor: accentColor,
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategorySelectionSection(
    BuildContext context,
    Color accentColor,
  ) {
    if (controller.hasInvestment && controller.investmentController != null) {
      return InvestmentAssetSelector(
        controller: controller.investmentController!,
        activeColor: accentColor,
      );
    }

    if (controller.hasBorrow && controller.liabilityController != null) {
      return BorrowAssetSelector(
        controller: controller.liabilityController!,
        activeColor: accentColor,
      );
    }

    if (controller.hasLend && controller.lendController != null) {
      return LendAssetSelector(
        controller: controller.lendController!,
        activeColor: accentColor,
      );
    }

    return Obx(() {
      final selectedCat = controller.selectedCategory.value;
      return CategorySelectionSection(
        type: controller.categoryType!,
        activeColor: accentColor,
        autoSelectFirst: false,
        initialSelectedCategoryId:
            selectedCat?.id ?? controller.transaction.categoryId,
        onCategorySelected: controller.setCategory,
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
        vertical: context.respPadding(CcPaddingParams.SPACE_SM),
      ),
      child: Row(
        children: [
          CcText(
            el.tr(PrjLocaleKeys.transaction_edit_title),
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context, Color accentColor) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
      ),
      child: Obx(
        () => PrjAmountInputSection(
          label: el.tr(PrjLocaleKeys.transaction_amount),
          amountStr: controller.amountStr.value,
          quickAmounts: MoneyConstants.getQuickAmounts(
            currencyCode: controller.currencyCode,
          ),
          hasKeypadVisible: controller.showKeypad.value,
          activeColor: accentColor,
          currencyCode: controller.currencyCode,
          onTap: controller.toggleKeypad,
          onQuickAmountSelected: controller.onQuickAmountSelected,
          onClear: controller.onClearAmount,
        ),
      ),
    );
  }

  Widget _buildDateAndNoteSection(BuildContext context) {
    final scheme = context.ccColorScheme;

    return CcNoteInputField(
      controller: controller.noteController,
      hintText: el.tr(PrjLocaleKeys.transaction_note_hint),
      maxLines: 2,
      color: scheme.surfaceVariant.withAlpha(80),
      borderColor: scheme.outlineVariant.withAlpha(10),
      height: context.respDim(45),
      margin: EdgeInsets.zero,
      showCopy: false,
    );
  }
}
