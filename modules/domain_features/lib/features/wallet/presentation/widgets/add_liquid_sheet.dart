import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../../core/helper/wallet_icon_helper.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
import '../../domain/entities/wallet_entity.dart';
import '../get_x/add_liquid_sheet_controller.dart';

class AddLiquidSheet extends GetView<AddLiquidSheetController> {
  const AddLiquidSheet({super.key, this.wallet});

  final WalletEntity? wallet;

  @override
  Widget build(BuildContext context) {
    return GetX<AddLiquidSheetController>(
      init: getIt<AddLiquidSheetController>()..init(wallet),
      dispose: (_) => Get.delete<AddLiquidSheetController>(),
      builder: (controller) {
        return Column(
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
              SafeArea(
                top: false,
                child: MoneyKeypadPanel(
                  onKeyPress: controller.handleKeyPress,
                  onDelete: controller.handleDelete,
                  onClear: () => controller.amountStr.value = '0',
                  suggestions: MoneyConstants.walletQuickAmounts,
                  onSuggestion: (value) =>
                      controller.amountStr.value = value.toString(),
                  onDone: controller.hideKeypad,
                  activeColor: context.ccColorScheme.primary,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSheetContent(
    BuildContext context,
    AddLiquidSheetController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context, controller),
        const CcSpaceSM(),
        if (!controller.isEditing) ...[
          _buildTypeSelector(context, controller),
          if (controller.showEmergencyFundLockedHint.value) ...[
            const CcSpaceXS(),
            _buildEmergencyFundLockedHint(context, controller),
          ],
          const CcSpaceMD(),
        ],
        _buildNameField(context, controller),
        const CcSpaceMD(),
        if (controller.balanceLocked)
          _buildLockedBalance(context, controller)
        else
          _buildAmountSection(context, controller),
        const CcSpaceMD(),
        _buildSaveButton(context, controller),
      ],
    );
  }

  Widget _buildTitle(
    BuildContext context,
    AddLiquidSheetController controller,
  ) {
    return CcFormLabel(
      text: controller.isEditing
          ? el.tr(CcLocaleKeys.wallet_edit_title)
          : el.tr(CcLocaleKeys.wallet_add_title),
      color: context.ccColorScheme.primary,
    );
  }

  Widget _buildNameField(
    BuildContext context,
    AddLiquidSheetController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcNameInputField(
          controller: controller.nameController,
          labelText: el.tr(CcLocaleKeys.wallet_name),
          hintText: el.tr(CcLocaleKeys.wallet_name_hint),
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

  Widget _buildAmountSection(
    BuildContext context,
    AddLiquidSheetController controller,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CcAmountInputSection(
          key: const Key('wallet_balance'),
          label: el.tr(CcLocaleKeys.wallet_initial_balance),
          amountStr: controller.amountStr.value,
          quickAmounts: MoneyConstants.walletQuickAmounts,
          isKeypadVisible: controller.showKeypad.value,
          activeColor: context.ccColorScheme.primary,
          fieldKey: controller.amountFieldKey,
          onTap: () => controller.showKeypadAndScroll(context),
          onQuickAmountSelected: (amount) =>
              controller.amountStr.value = amount.toString(),
          onClear: () => controller.amountStr.value = '0',
          onCopy: () =>
              CcStringHelper.copyToClipboard(controller.amountStr.value),
        ),
        if (Get.isRegistered<GuidelineController>())
          Obx(() {
            final guideline = Get.find<GuidelineController>();
            final showing =
                guideline.isTaskActive('wallet_balance') && controller.isCash;
            return Positioned(
              top: 0,
              right: 0,
              child: CcGuidelineBadge(
                showing: showing,
                color: guideline.currentColor,
                bounceTrigger: guideline.bounceTrigger,
                size: 10,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AddLiquidSheetController controller,
  ) {
    final bool canSave =
        controller.isNameValid.value &&
        (controller.newType.value != WalletType.investment ||
            controller.selectedInvestmentCategory.value != null);

    return CcSaveButton(
      onPressed: canSave ? () => controller.save(context) : null,
      label: el.tr(CcLocaleKeys.wallet_save_info),
    );
  }

  Widget _buildLockedBalance(
    BuildContext context,
    AddLiquidSheetController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcText(
          el.tr(CcLocaleKeys.wallet_initial_balance),
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
        const CcSpaceXS(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 54,
          decoration: BoxDecoration(
            color: context.ccColorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.ccColorScheme.outlineVariant.withOpacity(0.2),
            ),
          ),
          alignment: Alignment.center,
          child: CcText(
            '${TransactionFormHelpers.formatAmount(controller.amountStr.value)} đ',
            align: Alignment.center,
            textAlign: TextAlign.center,
            textStyle: context.ccTextTheme.headlineMedium?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: context.ccColorScheme.primary,
            ),
          ),
        ),
        const CcSpaceXS(),
        CcText(
          el.tr(CcLocaleKeys.wallet_balance_locked_hint),
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant.withAlpha(50),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyFundLockedHint(
    BuildContext context,
    AddLiquidSheetController controller,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(12),
        vertical: context.respPadding(10),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.onSurface.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: context.respIconSize(baseSize: 18),
            color: context.ccColorScheme.primary,
          ),
          const CcSpaceXS(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CcText(
                  el.tr(CcLocaleKeys.wallet_emergency_fund_locked_hint),
                  textStyle: context.ccTextTheme.bodySmall,
                ),
                const CcSpaceXS(),
                CcBouncing(
                  onTap: () => controller.openEmergencyFundEbook(context),
                  child: CcText(
                    el.tr(CcLocaleKeys.wallet_emergency_fund_view_ebook),
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      color: context.ccColorScheme.primary,
                      fontWeight: CcTypographyParams.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(
    BuildContext context,
    AddLiquidSheetController controller,
  ) {
    final options = [
      (WalletType.bank, el.tr(CcLocaleKeys.wallet_bank)),
      (WalletType.ewallet, el.tr(CcLocaleKeys.wallet_ewallet)),
      (WalletType.emergencyFund, el.tr(CcLocaleKeys.wallet_emergency_fund)),
    ];
    return HorizontalFadeScrollView(
      height: context.respDim(44),
      builder: (scrollController) => ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
          vertical: context.respDim(4),
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final (type, label) = options[index];
          final isSelected = controller.newType.value == type;
          return Padding(
            padding: EdgeInsets.only(right: context.respDim(8)),
            child: CcBouncing(
              onTap: () => controller.selectType(type),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: context.respDim(14),
                  vertical: context.respDim(10),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.ccColorScheme.primary
                      : context.ccColorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      walletIconFor(type),
                      size: context.respIconSize(baseSize: 16),
                      color: isSelected
                          ? context.ccColorScheme.onPrimary
                          : context.ccColorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: context.respDim(6)),
                    CcText(
                      label,
                      textStyle: context.ccTextTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? context.ccColorScheme.onPrimary
                            : context.ccColorScheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? CcTypographyParams.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
