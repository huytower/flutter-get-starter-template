import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../../guideline/export_guideline.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
import '../../domain/entities/budget_limit_entity.dart';
import '../get_x/add_budget_limit_sheet_controller.dart';
import 'budget_limit_category_selector.dart';
import 'budget_limit_lock_notice.dart';
import 'budget_limit_name_input.dart';

class AddBudgetLimitSheet extends GetView<AddBudgetLimitSheetController> {
  const AddBudgetLimitSheet({super.key, this.editTarget});

  final BudgetLimitEntity? editTarget;

  @override
  Widget build(BuildContext context) {
    return GetX<AddBudgetLimitSheetController>(
      init: getIt<AddBudgetLimitSheetController>()..init(editTarget),
      dispose: (_) => Get.delete<AddBudgetLimitSheetController>(),
      builder: (controller) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: context.respPadding(CcPaddingParams.SPACE_LG),
                  right: context.respPadding(CcPaddingParams.SPACE_LG),
                  top: context.respPadding(CcPaddingParams.SPACE_LG),
                  bottom: context.respPadding(CcPaddingParams.SPACE_LG),
                ),
                decoration: BoxDecoration(
                  color: context.ccColorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: _buildSheetContent(context, controller),
                ),
              ),
              if (controller.showKeypad.value)
                MoneyKeypadPanel(
                  onKeyPress: controller.onKeyPress,
                  onDelete: controller.onDeleteKey,
                  onClear: () => controller.limitStr.value = '0',
                  suggestions: MoneyConstants.budgetQuickAmounts,
                  onSuggestion: (value) =>
                      controller.limitStr.value = value.toString(),
                  onDone: controller.hideKeypad,
                  activeColor: context.ccColorScheme.primary,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetContent(
    BuildContext context,
    AddBudgetLimitSheetController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildTitle(context, controller)),
            if (!controller.limitLocked)
              _buildFixedPriceHeaderToggle(context, controller),
          ],
        ),
        const CcSpaceXS(),
        BudgetLimitNameInput(
          controller: controller.nameController,
          errorText: controller.nameError.value,
          onClear: () => controller.nameController.clear(),
          onTap: () {
            if (controller.showKeypad.value) {
              controller.hideKeypad();
            }
          },
        ),
        const CcSpaceXS(),
        if (!controller.isEdit) ...[
          BudgetLimitCategorySelector(
            categories: controller.categories,
            selectedCategoryId: controller.selectedCategoryId.value,
            onCategorySelected: (cat) {
              FocusScope.of(context).unfocus();
              controller.onCategorySelected(cat);
            },
            onScrollControllerCreated: (c) =>
                controller.categoryScrollController = c,
          ),
        ],
        const CcSpaceXS(),
        if (!controller.isEdit && controller.estimatedLimit.value != null)
          _buildEstimateSuggestion(context, controller),
        if (controller.limitLocked)
          const BudgetLimitLockNotice()
        else
          CcAmountInputSection(
            label: el.tr(CcLocaleKeys.budget_limit),
            amountStr: controller.limitStr.value,
            quickAmounts: MoneyConstants.budgetQuickAmounts,
            isKeypadVisible: controller.showKeypad.value,
            fieldKey: controller.amountFieldKey,
            onTap: () {
              controller.showKeypad.value = true;
              FocusScope.of(context).unfocus();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final ctx = controller.amountFieldKey.currentContext;
                if (ctx != null) {
                  Scrollable.ensureVisible(
                    ctx,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }
              });
            },
            onQuickAmountSelected: (amount) =>
                controller.limitStr.value = amount.toString(),
            onClear: () => controller.limitStr.value = '0',
            onCopy: () =>
                CcStringHelper.copyToClipboard(controller.limitStr.value),
          ),
        const CcSpaceSM(),
        Obx(
          () => CcSaveButton(
            onPressed: controller.isValid
                ? () => controller.save(context)
                : null,
            label: el.tr(CcLocaleKeys.common_save),
            isLoading: controller.isSubmitting.value,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(
    BuildContext context,
    AddBudgetLimitSheetController controller,
  ) {
    return CcFormLabel(
      text: controller.isEdit
          ? el.tr(CcLocaleKeys.budget_edit_title)
          : el.tr(CcLocaleKeys.budget_add_title),
      color: context.ccColorScheme.primary,
    );
  }

  Widget _buildFixedPriceHeaderToggle(
    BuildContext context,
    AddBudgetLimitSheetController controller,
  ) {
    final scheme = context.ccColorScheme;
    final guideline = Get.find<GuidelineController>();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CcBouncing(
          onTap: controller.toggleFixedPrice,
          borderRadius: context.brSm,
          child: Tooltip(
            message: el.tr(CcLocaleKeys.budget_fixed_price),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.respDim(8),
                vertical: context.respDim(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => CcIconToken(
                      Icons.bolt_rounded,
                      size: 18,
                      color: controller.isFixedPrice.value
                          ? scheme.primary
                          : scheme.outline,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.7,
                    child: Obx(
                      () => CcCheckBox(
                        isChecked: controller.isFixedPrice.value,
                        onChanged: (_) => controller.toggleFixedPrice(),
                        checkedColor: scheme.primary,
                        uncheckedBorderColor: scheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(() {
          if (!guideline.isTaskActive('min_living')) {
            return const SizedBox.shrink();
          }
          return Positioned(
            top: -4,
            left: 0,
            child: PrjGuidelineBadge(
              size: 4,
              label: guideline.bannerDescription,
              labelAbove: true,
              growRight: true,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEstimateSuggestion(
    BuildContext context,
    AddBudgetLimitSheetController controller,
  ) {
    final scheme = context.ccColorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: context.respDim(8)),
      child: CcBouncing(
        onTap: controller.applyEstimate,
        borderRadius: context.brMd,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.respDim(10),
            vertical: context.respDim(8),
          ),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.08),
            borderRadius: context.brMd,
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: context.respIconSize(baseSize: 16),
                color: scheme.primary,
              ),
              const CcSpaceXS(),
              Expanded(
                child: CcText(
                  el.tr(
                    CcLocaleKeys.budget_estimate_hint,
                    namedArgs: {
                      'amount': formatVndWithSymbol(
                        controller.estimatedLimit.value ?? 0,
                      ),
                    },
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textStyle: context.ccTextTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CcBouncing(
                onTap: controller.dismissEstimate,
                borderRadius: context.brSm,
                child: Icon(
                  Icons.close,
                  size: context.respIconSize(baseSize: 16),
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
