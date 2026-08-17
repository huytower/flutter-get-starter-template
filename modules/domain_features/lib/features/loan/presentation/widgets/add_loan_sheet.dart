import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../domain/entities/loan_entity.dart';
import '../get_x/add_loan_sheet_controller.dart';

class AddLoanSheet extends GetView<AddLoanSheetController> {
  const AddLoanSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AddLoanSheetController>(
      init: getIt<AddLoanSheetController>()..init(),
      dispose: (_) => Get.delete<AddLoanSheetController>(),
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(
                left: context.respPadding(CcPaddingParams.SPACE_LG),
                right: context.respPadding(CcPaddingParams.SPACE_LG),
                top: context.respPadding(CcPaddingParams.SPACE_LG),
                bottom:
                    MediaQuery.of(context).viewInsets.bottom +
                    context.respPadding(CcPaddingParams.SPACE_LG),
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
        );
      },
    );
  }

  Widget _buildSheetContent(
    BuildContext context,
    AddLoanSheetController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context, controller),
        const CcSpaceMD(),
        if (!controller.isVip.value) ...[
          const CcVipLockBanner(),
          const CcSpaceMD(),
        ],
        _buildDirectionPicker(context, controller),
        const CcSpaceMD(),
        _buildLoanCategoryPicker(context, controller),
        const CcSpaceMD(),
        _buildNameField(context, controller),
        const CcSpaceMD(),
        _buildSaveButton(context, controller),
      ],
    );
  }

  Widget _buildTitle(BuildContext context, AddLoanSheetController controller) {
    return CcText(
      el.tr(CcLocaleKeys.transaction_record_debt),
      textStyle: context.ccTextTheme.headlineSmall?.copyWith(
        fontWeight: CcTypographyParams.bold,
        color: context.ccColorScheme.primary,
      ),
    );
  }

  Widget _buildDirectionPicker(
    BuildContext context,
    AddLoanSheetController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => _buildDirectionButton(
              context,
              controller,
              LoanDirection.borrow,
              el.tr(CcLocaleKeys.transaction_loan_direction_borrow),
              Icons.call_made_rounded,
            ),
          ),
        ),
        const CcSpaceSM(),
        Expanded(
          child: Obx(
            () => _buildDirectionButton(
              context,
              controller,
              LoanDirection.lend,
              el.tr(CcLocaleKeys.transaction_loan_direction_lend),
              Icons.call_received_rounded,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionButton(
    BuildContext context,
    AddLoanSheetController controller,
    String direction,
    String label,
    IconData icon,
  ) {
    final isSelected = controller.direction.value == direction;
    final scheme = context.ccColorScheme;

    return CcInkWell(
      onTap: () => controller.setDirection(direction),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.respPadding(CcPaddingParams.SPACE_MD),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primaryContainer.withValues(alpha: 0.2)
              : scheme.onSurface.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? scheme.primary.withOpacity(0.3)
                : scheme.onSurface.withOpacity(0.08),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: context.respIconSize(baseSize: 18),
              color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const CcSpaceSM(),
            CcText(
              label,
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                fontWeight: isSelected
                    ? CcTypographyParams.bold
                    : FontWeight.normal,
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCategoryPicker(
    BuildContext context,
    AddLoanSheetController controller,
  ) {
    return Obx(() {
      final categories = controller.loanCategories.toList();
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
                      controller.selectedLoanCategory.value?.id == category.id;
                  return CcCategoryItem(
                    iconCode: category.iconCode,
                    iconFamily: category.iconFamily,
                    nameKey: category.nameKey,
                    isSelected: isSelected,
                    onTap: () => controller.selectLoanCategory(category),
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
    AddLoanSheetController controller,
  ) {
    return CcNameInputField(
      controller: controller.nameController,
      labelText: el.tr(CcLocaleKeys.transaction_loan_name_label),
      hintText: el.tr(CcLocaleKeys.transaction_loan_name_hint),
      onClear: () {
        controller.isNameValid.value = false;
        controller.selectedLoanCategory.value = null;
      },
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AddLoanSheetController controller,
  ) {
    return Obx(() {
      final bool canSave =
          controller.selectedLoanCategory.value != null &&
          !controller.isSubmitting.value;

      return CcSaveButton(
        onPressed: canSave ? () => controller.save(context) : null,
        label: el.tr(CcLocaleKeys.common_save),
        isLoading: controller.isSubmitting.value,
      );
    });
  }
}
