import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/wallet_icon_helper.dart';
import '../../domain/entities/wallet_entity.dart';
import '../get_x/add_investment_sheet_controller.dart';

class AddInvestmentSheet extends StatefulWidget {
  const AddInvestmentSheet({super.key, this.wallet});

  final WalletEntity? wallet;

  @override
  State<AddInvestmentSheet> createState() => _AddInvestmentSheetState();
}

class _AddInvestmentSheetState extends State<AddInvestmentSheet> {
  late final AddInvestmentSheetController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(getIt<AddInvestmentSheetController>());
    _controller.init(widget.wallet);
  }

  @override
  void dispose() {
    Get.delete<AddInvestmentSheetController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
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
              child: _buildSheetContent(context, _controller),
            ),
          ),
        ],
      ),
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
          _buildVipLockBanner(context),
          const CcSpaceMD(),
        ],
        _buildInvestmentCategoryPicker(context, controller),
        const CcSpaceMD(),
        _buildNameField(controller),
        const CcSpaceMD(),
        _buildSaveButton(context, controller),
      ],
    );
  }

  Widget _buildVipLockBanner(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      decoration: BoxDecoration(
        color: context.ccColorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.ccColorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            color: context.ccColorScheme.primary,
            size: context.respIconSize(baseSize: 24),
          ),
          const CcSpaceSM(),
          Expanded(
            child: CcText(
              el.tr(CcLocaleKeys.profile_vip_subtitle),
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                color: context.ccColorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(
    BuildContext context,
    AddInvestmentSheetController controller,
  ) {
    return CcText(
      controller.isEditing
          ? el.tr(CcLocaleKeys.wallet_edit_title)
          : el.tr(CcLocaleKeys.transaction_record_investment),
      textStyle: context.ccTextTheme.headlineSmall?.copyWith(
        fontWeight: CcTypographyParams.bold,
        color: context.ccColorScheme.primary,
      ),
    );
  }

  Widget _buildInvestmentCategoryPicker(
    BuildContext context,
    AddInvestmentSheetController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcText(
          el.tr(CcLocaleKeys.transaction_category),
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
        const CcSpaceXS(),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.investmentCategories.map((category) {
              final isSelected =
                  controller.selectedInvestmentCategory.value?.id ==
                  category.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CcInkWell(
                  onTap: () => controller.selectInvestmentCategory(category),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.ccColorScheme.primary.withOpacity(0.1)
                          : context.ccColorScheme.surfaceVariant.withOpacity(
                              0.5,
                            ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? context.ccColorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          iconDataFromCode(
                            category.iconCode,
                            fontFamily: category.iconFamily,
                          ),
                          size: 24,
                          color: isSelected
                              ? context.ccColorScheme.primary
                              : context.ccColorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 4),
                        CcText(
                          el.tr(category.nameKey),
                          textStyle: context.ccTextTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? context.ccColorScheme.primary
                                : context.ccColorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(AddInvestmentSheetController controller) {
    return TextField(
      controller: controller.nameController,
      maxLength: 20,
      decoration: InputDecoration(
        labelText: el.tr(CcLocaleKeys.wallet_investment_name),
        hintText: el.tr(CcLocaleKeys.wallet_investment_name_hint),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
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

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: SizedBox(
          height: context.respDim(40),
          child: ElevatedButton(
            onPressed: canSave ? () => controller.save(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.ccColorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: CcText(
              el.tr(CcLocaleKeys.wallet_save_info),
              align: Alignment.center,
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: context.ccColorScheme.onPrimary,
                fontWeight: CcTypographyParams.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
