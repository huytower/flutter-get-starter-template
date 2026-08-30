import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../domain/entities/liability_entity.dart';
import '../get_x/add_liability_sheet_controller.dart';

class AddLiabilitySheet extends GetView<AddLiabilitySheetController> {
  const AddLiabilitySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AddLiabilitySheetController>(
      init: getIt<AddLiabilitySheetController>()..init(),
      dispose: (_) => Get.delete<AddLiabilitySheetController>(),
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
    AddLiabilitySheetController controller,
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

  Widget _buildTitle(
    BuildContext context,
    AddLiabilitySheetController controller,
  ) {
    return CcFormLabel(
      text: el.tr(CcLocaleKeys.transaction_record_debt),
      color: context.ccColorScheme.primary,
    );
  }

  Widget _buildDirectionPicker(
    BuildContext context,
    AddLiabilitySheetController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => _buildDirectionButton(
              context,
              controller,
              LiabilityDirection.borrow,
              el.tr(CcLocaleKeys.transaction_liability_direction_borrow),
              Icons.waving_hand,
            ),
          ),
        ),
        const CcSpaceSM(),
        Expanded(
          child: Obx(
            () => _buildDirectionButton(
              context,
              controller,
              LiabilityDirection.lend,
              el.tr(CcLocaleKeys.transaction_liability_direction_lend),
              Icons.handshake_outlined,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionButton(
    BuildContext context,
    AddLiabilitySheetController controller,
    String direction,
    String label,
    IconData icon,
  ) {
    final isSelected = controller.direction.value == direction;
    final scheme = context.ccColorScheme;

    return CcBouncing(
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
    AddLiabilitySheetController controller,
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
    AddLiabilitySheetController controller,
  ) {
    return Column(
      children: [
        CcNameInputField(
          controller: controller.nameController,
          labelText: el.tr(CcLocaleKeys.transaction_liability_name_label),
          hintText: el.tr(CcLocaleKeys.transaction_liability_name_hint),
          onClear: () {
            controller.isNameValid.value = false;
            controller.selectedLoanCategory.value = null;
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
    AddLiabilitySheetController controller,
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
