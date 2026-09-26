import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../liability/presentation/widgets/liability_asset_selector.dart';
import '../../../liability/presentation/widgets/lend_asset_selector.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/presentation/widgets/category_selection_section.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/investment_asset_selector.dart';
import '../../../transaction/presentation/widgets/transaction_form_container.dart';
import '../../../transaction/presentation/widgets/transaction_submit_button.dart';
import '../get_x/quick_edit_transaction_sheet_controller.dart';

class QuickEditTransactionSheet
    extends GetView<QuickEditTransactionSheetController> {
  const QuickEditTransactionSheet({super.key});

  static Future<void> show(
    BuildContext context,
    TransactionEntity transaction,
  ) {
    final controller = Get.put(getIt<QuickEditTransactionSheetController>());
    controller.init(transaction, () {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
                      TransactionFormContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_buildDateAndNoteSection(context)],
                        ),
                      ),
                      const CcSpaceSM(),
                      TransactionSubmitButton(
                        text: el.tr(CcLocaleKeys.common_save),
                        isSubmitting: controller.isSubmitting.value,
                        isEnabled: true,
                        onTap: () => controller.save(context),
                        activeColor: accentColor,
                      ),
                      const CcSpaceXS(),
                    ],
                  ),
                ),
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
    if (controller.isInvestment && controller.investmentController != null) {
      return InvestmentAssetSelector(
        controller: controller.investmentController!,
        activeColor: accentColor,
      );
    }

    if (controller.isBorrow && controller.liabilityController != null) {
      return LiabilityAssetSelector(
        controller: controller.liabilityController!,
        activeColor: accentColor,
      );
    }

    if (controller.isLend && controller.lendController != null) {
      return LendAssetSelector(
        controller: controller.lendController!,
        activeColor: accentColor,
      );
    }

    return CategorySelectionSection(
      type: controller.categoryType!,
      activeColor: accentColor,
      autoSelectFirst: false,
      initialSelectedCategoryId: controller.transaction.categoryId,
      onCategorySelected: controller.setCategory,
    );
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
            el.tr(CcLocaleKeys.transaction_edit_title),
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
        () => CcAmountInputSection(
          label: el.tr(CcLocaleKeys.transaction_amount),
          amountStr: controller.amountStr.value,
          quickAmounts: const [
            10000,
            20000,
            50000,
            100000,
            200000,
            500000,
            1000000,
          ],
          isKeypadVisible: false,
          activeColor: accentColor,
          onTap: () {},
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
      hintText: el.tr(CcLocaleKeys.transaction_note_hint),
      maxLines: 2,
      color: scheme.surfaceVariant.withAlpha(80),
      borderColor: scheme.outlineVariant.withAlpha(10),
      height: context.respDim(45),
      margin: EdgeInsets.zero,
      showCopy: false,
    );
  }
}
