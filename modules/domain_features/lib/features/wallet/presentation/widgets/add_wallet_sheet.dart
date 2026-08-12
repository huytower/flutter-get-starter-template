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
import '../get_x/add_wallet_sheet_controller.dart';

/// Bottom sheet for creating a new wallet, or editing an existing one when
/// [wallet] is provided. Shared by the Wallets tab and Budget Allocation's
/// "add wallet" entry point.
class AddWalletSheet extends StatefulWidget {
  const AddWalletSheet({super.key, this.wallet});

  final WalletEntity? wallet;

  @override
  State<AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends State<AddWalletSheet> {
  late final AddWalletSheetController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(getIt<AddWalletSheetController>());
    _controller.init(widget.wallet);
  }

  @override
  void dispose() {
    Get.delete<AddWalletSheetController>();
    super.dispose();
  }

  Color get _accent => context.ccColorScheme.primary;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (_controller.showKeypad.value) _controller.hideKeypad();
            },
            child: Container(
              padding: EdgeInsets.only(
                left: context.respPadding(CcPaddingParams.SPACE_LG),
                right: context.respPadding(CcPaddingParams.SPACE_LG),
                top: context.respPadding(CcPaddingParams.SPACE_LG),
                bottom:
                    (_controller.showKeypad.value
                        ? 0
                        : MediaQuery.of(context).viewInsets.bottom) +
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
          ),
          if (_controller.showKeypad.value)
            SafeArea(
              top: false,
              child: MoneyKeypadPanel(
                onKeyPress: _controller.handleKeyPress,
                onDelete: _controller.handleDelete,
                onClear: () => _controller.amountStr.value = '0',
                suggestions: MoneyConstants.walletQuickAmounts,
                onSuggestion: (value) =>
                    _controller.amountStr.value = value.toString(),
                onDone: _controller.hideKeypad,
                activeColor: _accent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSheetContent(
    BuildContext context,
    AddWalletSheetController controller,
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
        if (controller.newType.value == WalletType.investment) ...[
          _buildInvestmentCategoryPicker(context, controller),
          const CcSpaceMD(),
        ],
        _buildNameField(controller),
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
    AddWalletSheetController controller,
  ) {
    return CcText(
      controller.isEditing
          ? el.tr(CcLocaleKeys.wallet_edit_title)
          : el.tr(CcLocaleKeys.wallet_add_title),
      textStyle: context.ccTextTheme.headlineSmall?.copyWith(
        fontWeight: CcTypographyParams.bold,
        color: context.ccColorScheme.primary,
      ),
    );
  }

  Widget _buildNameField(AddWalletSheetController controller) {
    return TextField(
      controller: controller.nameController,
      maxLength: 20,
      decoration: InputDecoration(
        labelText: el.tr(CcLocaleKeys.wallet_name),
        hintText: el.tr(CcLocaleKeys.wallet_name_hint),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAmountSection(
    BuildContext context,
    AddWalletSheetController controller,
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
          activeColor: _accent,
          fieldKey: controller.amountFieldKey,
          onTap: () => controller.showKeypadAndScroll(context),
          onQuickAmountSelected: (amount) =>
              controller.amountStr.value = amount.toString(),
        ),
        if (Get.isRegistered<GuidelineController>())
          Obx(() {
            final guideline = Get.find<GuidelineController>();
            final showing =
                guideline.isTaskActive('reconcile_wallet') && controller.isCash;
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
    AddWalletSheetController controller,
  ) {
    final bool canSave =
        controller.isNameValid.value &&
        (controller.newType.value != WalletType.investment ||
            controller.selectedInvestmentCategory.value != null);

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

  /// Read-only display for a balance that can no longer be edited (a wallet
  /// that already has transactions).
  Widget _buildLockedBalance(
    BuildContext context,
    AddWalletSheetController controller,
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
            color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyFundLockedHint(
    BuildContext context,
    AddWalletSheetController controller,
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
            color: _accent,
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
                CcInkWell(
                  onTap: () => controller.openEmergencyFundEbook(context),
                  child: CcText(
                    el.tr(CcLocaleKeys.wallet_emergency_fund_view_ebook),
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      color: _accent,
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
    AddWalletSheetController controller,
  ) {
    final canUseInvestment =
        controller.userLevel.status.value.level >= 2 ||
        CcFeatureFlags.isForceFullAccessEnabled;

    final options = [
      (WalletType.bank, el.tr(CcLocaleKeys.wallet_bank)),
      (WalletType.ewallet, el.tr(CcLocaleKeys.wallet_ewallet)),
      (WalletType.emergencyFund, el.tr(CcLocaleKeys.wallet_emergency_fund)),
      if (canUseInvestment)
        (WalletType.investment, el.tr(CcLocaleKeys.transaction_investment)),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final (type, label) = option;
          final isSelected = controller.newType.value == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CcInkWell(
              onTap: () => controller.selectType(type),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
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
                      size: 16,
                      color: isSelected
                          ? context.ccColorScheme.onPrimary
                          : context.ccColorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
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
        }).toList(),
      ),
    );
  }

  Widget _buildInvestmentCategoryPicker(
    BuildContext context,
    AddWalletSheetController controller,
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
                          iconDataFromCode(category.iconCode),
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
}
