import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/domain/entities/liability_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/di/di.dart';
import '../../../../core/presentation/helper/name_suggestions.dart';
import '../../../../core/presentation/widgets/category/prj_category_item.dart';
import '../../../../core/presentation/widgets/prj_suggested_name_field.dart';
import '../get_x/add_liability_sheet_controller.dart';
import '../helper/liability_name_suggestions.dart';

class AddLiabilitySheet extends GetView<AddLiabilitySheetController> {
  const AddLiabilitySheet({
    super.key,
    this.initialDirection = LiabilityDirection.borrow,
    this.showDirectionToggle = false,
  });

  final String initialDirection;
  final bool showDirectionToggle;

  static Future<bool?> show(
    BuildContext context, {
    String initialDirection = LiabilityDirection.borrow,
    bool showDirectionToggle = false,
  }) {
    return CcAdaptiveBottomSheet.show<bool>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddLiabilitySheet(
        initialDirection: initialDirection,
        showDirectionToggle: showDirectionToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddLiabilitySheetController>(
      init: getIt<AddLiabilitySheetController>()
        ..prepareForm(
          initialDirection: initialDirection,
          showDirectionToggle: showDirectionToggle,
        ),
      dispose: (_) => Get.delete<AddLiabilitySheetController>(),
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
    AddLiabilitySheetController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context, controller),
        const CcSpaceMD(),
        if (controller.showDirectionToggle.value) ...[
          _buildDirectionPicker(context, controller),
          const CcSpaceMD(),
        ],
        _buildLiabilityCategoryPicker(context, controller),
        const CcSpaceMD(),
        _buildNameField(controller),
        const CcSpaceMD(),
        _buildSaveButton(context, controller),
      ],
    );
  }

  Widget _buildTitle(
    BuildContext context,
    AddLiabilitySheetController controller,
  ) {
    return Obx(() {
      final titleKey = controller.direction.value == LiabilityDirection.lend
          ? PrjLocaleKeys.transaction_liability_direction_lend
          : PrjLocaleKeys.transaction_record_debt;

      return CcFormLabel(
        text: el.tr(titleKey),
        color: context.ccColorScheme.primary,
      );
    });
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
              el.tr(PrjLocaleKeys.transaction_liability_direction_borrow),
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
              el.tr(PrjLocaleKeys.transaction_liability_direction_lend),
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
    final hasSelected = controller.direction.value == direction;
    final scheme = context.ccColorScheme;

    return CcBouncing(
      onTap: () => controller.setDirection(direction),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.respPadding(CcPaddingParams.SPACE_MD),
        ),
        decoration: BoxDecoration(
          color: hasSelected
              ? scheme.primaryContainer.withValues(alpha: 0.2)
              : scheme.onSurface.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasSelected
                ? scheme.primary.withOpacity(0.3)
                : scheme.onSurface.withOpacity(0.08),
            width: hasSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: context.respIconSize(baseSize: 18),
              color: hasSelected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const CcSpaceSM(),
            CcText(
              label,
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                fontWeight: hasSelected
                    ? CcTypographyParams.bold
                    : FontWeight.normal,
                color: hasSelected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiabilityCategoryPicker(
    BuildContext context,
    AddLiabilitySheetController controller,
  ) {
    return Obx(() {
      final categories = controller.liabilityCategories.toList();
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
                      controller.selectedLiabilityCategory.value?.id ==
                      category.id;
                  return PrjCategoryItem(
                    iconCode: category.iconCode,
                    iconFamily: category.iconFamily,
                    label: el.tr(category.nameKey),
                    hasSelected: hasSelected,
                    onTap: () => controller.selectLiabilityCategory(category),
                  );
                });
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildNameField(AddLiabilitySheetController controller) {
    return Obx(
      () => PrjSuggestedNameField(
        controller: controller.nameController,
        labelText: el.tr(PrjLocaleKeys.transaction_liability_name_label),
        maxLength: 25,
        suggestions: NameSuggestions.fromKey(
          LiabilityNameSuggestions.keyFor(
            controller.selectedLiabilityCategory.value?.id,
          ),
        ),
        errorText: controller.nameError.value,
        // Keeps the category (and its suggestions) so the user can pick one.
        onClear: () => controller.nameError.value = null,
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AddLiabilitySheetController controller,
  ) {
    return Obx(() {
      final bool canSave =
          controller.selectedLiabilityCategory.value != null &&
          controller.hasNameValid.value &&
          !controller.hasSubmitting.value;

      return CcSaveButton(
        onPressed: canSave ? () => controller.save(context) : null,
        label: el.tr(PrjLocaleKeys.common_save),
        hasLoading: controller.hasSubmitting.value,
      );
    });
  }
}
