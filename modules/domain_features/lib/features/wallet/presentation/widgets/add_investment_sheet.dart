import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../domain/entities/wallet_entity.dart';
import '../get_x/add_investment_sheet_controller.dart';

class AddInvestmentSheet extends GetView<AddInvestmentSheetController> {
  const AddInvestmentSheet({super.key, this.wallet, this.category});

  final WalletEntity? wallet;
  final CategoryEntity? category;

  @override
  Widget build(BuildContext context) {
    return GetX<AddInvestmentSheetController>(
      init: getIt<AddInvestmentSheetController>()
        ..init(wallet, category: category),
      dispose: (_) => Get.delete<AddInvestmentSheetController>(),
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
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom +
                      context.respPadding(CcPaddingParams.SPACE_MD),
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetContent(
    BuildContext context,
    AddInvestmentSheetController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context, controller),
        const CcSpaceMD(),
        if (!controller.isVip.value && !controller.isEditing) ...[
          const CcVipLockBanner(),
          const CcSpaceMD(),
        ],
        _buildInvestmentCategoryPicker(context, controller),
        const CcSpaceMD(),
        _buildNameField(context, controller),
        const CcSpaceMD(),
        _buildSaveButton(context, controller),
      ],
    );
  }

  Widget _buildTitle(
    BuildContext context,
    AddInvestmentSheetController controller,
  ) {
    return CcFormLabel(
      text: controller.isEditing
          ? el.tr(CcLocaleKeys.wallet_investment_edit_title)
          : el.tr(CcLocaleKeys.transaction_record_investment),
      color: context.ccColorScheme.primary,
    );
  }

  Widget _buildInvestmentCategoryPicker(
    BuildContext context,
    AddInvestmentSheetController controller,
  ) {
    return Obx(() {
      final categories = controller.investmentCategories.toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            el.tr(CcLocaleKeys.transaction_category),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const CcSpaceSM(),
          HorizontalFadeScrollView(
            height: context.respDim(80),
            builder: (scrollController) => ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const CcSpaceSM(),
              itemBuilder: (context, index) {
                final category = categories[index];
                return Obx(() {
                  final isSelected =
                      controller.selectedInvestmentCategory.value?.id ==
                      category.id;
                  return CcCategoryItem(
                    iconCode: category.iconCode,
                    iconFamily: category.iconFamily,
                    nameKey: category.nameKey,
                    isSelected: isSelected,
                    onTap: () => controller.selectInvestmentCategory(category),
                  );
                });
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildNameField(
    BuildContext context,
    AddInvestmentSheetController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcNameInputField(
          controller: controller.nameController,
          labelText: el.tr(CcLocaleKeys.wallet_investment_name),
          hintText: el.tr(CcLocaleKeys.wallet_investment_name_hint),
          onClear: () {
            controller.isNameValid.value = false;
            controller.selectedInvestmentCategory.value = null;
            controller.nameError.value = null;
          },
        ),
        Obx(() {
          if (controller.nameError.value == null) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: EdgeInsets.only(
              left: context.respPadding(CcPaddingParams.DESC_XS),
              top: context.respPadding(CcPaddingParams.DESC_XS),
            ),
            child: CcText(
              controller.nameError.value!,
              textStyle: context.ccTextTheme.labelSmall?.copyWith(
                color: context.ccColorScheme.error,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AddInvestmentSheetController controller,
  ) {
    final bool canSave =
        controller.isNameValid.value &&
        controller.selectedInvestmentCategory.value != null &&
        (controller.isVip.value || controller.isEditing);

    return CcSaveButton(
      onPressed: canSave ? () => controller.save(context) : null,
      label: el.tr(CcLocaleKeys.common_save),
    );
  }
}
