import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/wallet_icon_helper.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../domain/entities/loan_entity.dart';
import '../get_x/add_loan_sheet_controller.dart';

class AddLoanSheet extends StatefulWidget {
  const AddLoanSheet({super.key});

  @override
  State<AddLoanSheet> createState() => _AddLoanSheetState();
}

class _AddLoanSheetState extends State<AddLoanSheet> {
  late final AddLoanSheetController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(getIt<AddLoanSheetController>());
    _controller.init();
  }

  @override
  void dispose() {
    Get.delete<AddLoanSheetController>();
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
    AddLoanSheetController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context, controller),
        const CcSpaceMD(),
        if (!controller.isVip.value) ...[
          _buildVipLockBanner(context),
          const CcSpaceMD(),
        ],
        _buildDirectionPicker(context, controller),
        const CcSpaceMD(),
        _buildLoanCategoryPicker(context, controller),
        const CcSpaceMD(),
        _buildCounterpartyField(controller),
        const CcSpaceMD(),
        _buildAmountField(context, controller),
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
            const SizedBox(width: 8),
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
            itemCount: controller.loanCategories.length,
            separatorBuilder: (_, _) => const CcSpaceSM(),
            itemBuilder: (context, index) {
              final category = controller.loanCategories[index];
              final isSelected =
                  controller.selectedLoanCategory.value?.id == category.id;
              return _buildCategoryItem(
                context,
                controller,
                category,
                isSelected,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    AddLoanSheetController controller,
    CategoryEntity category,
    bool isSelected,
  ) {
    final scheme = context.ccColorScheme;

    return CcInkWell(
      onTap: () => controller.selectLoanCategory(category),
      borderRadius: context.brLg,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isSelected)
            const Positioned.fill(child: CcGlassyGradientBackground()),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: context.respDim(50),
            decoration: BoxDecoration(
              color: isSelected
                  ? scheme.primaryContainer.withValues(alpha: 0.1)
                  : scheme.onSurface.withOpacity(0.04),
              borderRadius: context.brLg,
              border: Border.all(
                color: isSelected
                    ? scheme.primary.withOpacity(0.2)
                    : scheme.onSurface.withOpacity(0.08),
                width: context.respDim(1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCategoryIcon(context, category, isSelected),
                const CcSpaceXS(),
                Text(
                  el.tr(category.nameKey),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.ccTextTheme.labelSmall?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(
    BuildContext context,
    CategoryEntity cat,
    bool isSelected,
  ) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(32),
      height: context.respDim(32),
      decoration: BoxDecoration(
        color: isSelected
            ? scheme.primary.withOpacity(0.12)
            : scheme.onSurface.withOpacity(0.08),
        borderRadius: context.brMd,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected) const Positioned.fill(child: CcGlassyGradientIcon()),
          CcIcon(
            icon: iconDataFromCode(cat.iconCode, fontFamily: cat.iconFamily),
            size: context.respIconSize(baseSize: 18),
            color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterpartyField(AddLoanSheetController controller) {
    return TextField(
      controller: controller.counterpartyController,
      maxLength: 30,
      decoration: InputDecoration(
        labelText: el.tr(CcLocaleKeys.transaction_loan_borrower_label),
        hintText: el.tr(CcLocaleKeys.transaction_loan_borrower_hint),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAmountField(
    BuildContext context,
    AddLoanSheetController controller,
  ) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            el.tr(CcLocaleKeys.transaction_amount),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const CcSpaceSM(),
          Container(
            key: controller.amountFieldKey,
            padding: EdgeInsets.all(
              context.respPadding(CcPaddingParams.SPACE_MD),
            ),
            decoration: BoxDecoration(
              color: context.ccColorScheme.onSurface.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.ccColorScheme.onSurface.withOpacity(0.08),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CcText(
                  controller.amountStr.value,
                  key: ValueKey(controller.amountStr.value),
                  textStyle: context.ccTextTheme.headlineMedium?.copyWith(
                    fontWeight: CcTypographyParams.bold,
                    color: context.ccColorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    _buildKeypadButton(
                      context,
                      controller,
                      Icons.backspace_outlined,
                      () => controller.handleDelete(),
                    ),
                    const SizedBox(width: 8),
                    _buildKeypadButton(
                      context,
                      controller,
                      Icons.keyboard_outlined,
                      () => controller.showKeypadAndScroll(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (controller.showKeypad.value) ...[
            const CcSpaceMD(),
            _buildNumberKeypad(context, controller),
          ],
        ],
      ),
    );
  }

  Widget _buildKeypadButton(
    BuildContext context,
    AddLoanSheetController controller,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      padding: EdgeInsets.all(context.respDim(8)),
      decoration: BoxDecoration(
        color: context.ccColorScheme.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: context.respIconSize(baseSize: 20),
        color: context.ccColorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildNumberKeypad(
    BuildContext context,
    AddLoanSheetController controller,
  ) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['000', '0', 'C'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: EdgeInsets.only(bottom: context.respDim(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.respDim(4)),
                  child: _buildKeypadKey(context, controller, key),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadKey(
    BuildContext context,
    AddLoanSheetController controller,
    String key,
  ) {
    return CcInkWell(
      onTap: () {
        if (key == 'C') {
          controller.amountStr.value = '0';
        } else {
          controller.handleKeyPress(key);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: context.respDim(50),
        decoration: BoxDecoration(
          color: context.ccColorScheme.onSurface.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CcText(
            key,
            textStyle: context.ccTextTheme.titleLarge?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: context.ccColorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AddLoanSheetController controller,
  ) {
    final bool canSave =
        controller.isCounterpartyValid.value &&
        controller.selectedLoanCategory.value != null &&
        (int.tryParse(controller.amountStr.value) ?? 0) > 0 &&
        !controller.isSubmitting.value;

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
            child: controller.isSubmitting.value
                ? SizedBox(
                    width: context.respDim(20),
                    height: context.respDim(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.ccColorScheme.onPrimary,
                    ),
                  )
                : CcText(
                    el.tr(CcLocaleKeys.common_save),
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
