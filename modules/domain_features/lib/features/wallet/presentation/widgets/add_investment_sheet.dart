import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/domain/entities/category_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/di/di.dart';
import '../../../../core/presentation/helper/name_suggestions.dart';
import '../../../../core/presentation/widgets/category/prj_category_item.dart';
import '../../../../core/presentation/widgets/prj_suggested_name_field.dart';
import '../../../../core/presentation/widgets/prj_vip_lock_banner.dart';
import '../get_x/add_investment_sheet_controller.dart';

class AddInvestmentSheet extends GetView<AddInvestmentSheetController> {
  const AddInvestmentSheet({super.key, this.wallet, this.category});

  final WalletEntity? wallet;
  final CategoryEntity? category;

  @override
  Widget build(BuildContext context) {
    return GetX<AddInvestmentSheetController>(
      init: getIt<AddInvestmentSheetController>()
        ..prepareForm(wallet, category: category),
      dispose: (_) => Get.delete<AddInvestmentSheetController>(),
      builder: (controller) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shrinks and scrolls when the window is short (landscape), so
              // the rest of the sheet (e.g. the keypad) always fits.
              Flexible(
                child: Container(
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
        if (!controller.hasVip.value && !controller.hasEditing) ...[
          const PrjVipLockBanner(),
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
      text: controller.hasEditing
          ? el.tr(PrjLocaleKeys.wallet_investment_edit_title)
          : el.tr(PrjLocaleKeys.transaction_record_investment),
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
            el.tr(PrjLocaleKeys.transaction_category),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const CcSpaceSM(),
          CcHorizontalFadeScrollView(
            height: context.respDim(80),
            builder: (scrollController) => ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const CcSpaceSM(),
              itemBuilder: (context, index) {
                final category = categories[index];
                return Obx(() {
                  final hasSelected =
                      controller.selectedInvestmentCategory.value?.id ==
                      category.id;
                  return PrjCategoryItem(
                    iconCode: category.iconCode,
                    iconFamily: category.iconFamily,
                    label: el.tr(category.nameKey),
                    hasSelected: hasSelected,
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
    return Obx(
      () => PrjSuggestedNameField(
        controller: controller.nameController,
        labelText: el.tr(PrjLocaleKeys.wallet_investment_name),
        // Room for the longest regional fund names.
        maxLength: 30,
        suggestions: NameSuggestions.fromNames(controller.nameSuggestions),
        errorText: controller.nameError.value,
        // Keeps the category (and its suggestions) so the user can pick one.
        onClear: () => controller.nameError.value = null,
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AddInvestmentSheetController controller,
  ) {
    final bool canSave =
        controller.hasNameValid.value &&
        controller.selectedInvestmentCategory.value != null &&
        (controller.hasVip.value || controller.hasEditing);

    return CcSaveButton(
      onPressed: canSave ? () => controller.save(context) : null,
      label: el.tr(PrjLocaleKeys.common_save),
    );
  }
}
