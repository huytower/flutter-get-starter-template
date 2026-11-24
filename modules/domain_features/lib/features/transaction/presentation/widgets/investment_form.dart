import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/di/di.dart';
import 'package:domain_features/core/presentation/widgets/entry_additional_details_section.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/budget/budget_name_helper.dart';
import '../../../guideline/presentation/widgets/prj_guideline_badge.dart';
import '../../domain/entities/investment_direction.dart';
import '../get_x/investment_form_controller.dart';
import '../get_x/transaction_controller.dart';
import 'form_amount_section.dart';
import 'form_keypad_panel.dart';
import 'form_wallet_section.dart';
import 'investment_asset_selector.dart';
import 'investment_direction_toggle.dart';

class InvestmentForm extends StatefulWidget {
  const InvestmentForm({super.key});

  @override
  State<InvestmentForm> createState() => _InvestmentFormState();
}

class _InvestmentFormState extends State<InvestmentForm> {
  late final InvestmentFormController controller;
  final GlobalKey _amountFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = Get.find<InvestmentFormController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.loadSuggestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final accentColor = _accentColor(context, controller.direction.value);
      final guideline = getIt<GuidelineProvider>();

      return Column(
        children: [
          Expanded(
            child: _buildScrollableContent(
              context,
              controller,
              accentColor,
              guideline,
            ),
          ),
          if (controller.showKeypad.value)
            _buildMoneyKeypadPanel(context, controller, accentColor),
        ],
      );
    });
  }

  Color _accentColor(BuildContext context, InvestmentDirection direction) =>
      direction == InvestmentDirection.contribute
      ? context.investmentAccent
      : context.investmentAccent.secondaryShade;

  Widget _buildScrollableContent(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
    GuidelineProvider guideline,
  ) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        controller.hideKeypad();
      },
      child: SingleChildScrollView(
        controller: controller.scrollController,
        child: CcFormTwoColumn.shouldUse(context)
            ? _buildTwoColumnContent(context, controller, accentColor)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInvestDirectionToggle(context, controller, accentColor),
                  const CcSpaceSM(),
                  InvestmentAssetSelector(
                    controller: controller,
                    activeColor: accentColor,
                  ),
                  const CcSpaceSM(),
                  _buildFormFields(context, controller, accentColor),
                ],
              ),
      ),
    );
  }

  /// Landscape tablet: direction toggle, asset selector and date/note on the
  /// left; amount, wallet, new-item name and submit on the right.
  Widget _buildTwoColumnContent(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return CcFormTwoColumn(
      leading: [
        buildInvestDirectionToggle(context, controller, accentColor),
        const CcSpaceSM(),
        InvestmentAssetSelector(
          controller: controller,
          activeColor: accentColor,
        ),
      ],
      details: Obx(
        () => EntryAdditionalDetailsSection(
          hasExpanded: true,
          selectedDate: controller.date.value,
          onDateSelected: controller.setDate,
          onCalendarTap: () => controller.pickDate(context),
          noteController: controller.noteController,
          activeColor: accentColor,
        ),
      ),
      right: [
        _buildAmountSection(context, controller, accentColor),
        const CcSpaceSM(),
        Obx(() => _buildWalletSection(context, controller, accentColor)),
        const CcSpaceSM(),
        _buildNewItemSection(context, controller, accentColor),
        _buildSubmitButton(context, controller, accentColor),
        const CcSpaceXS(),
      ],
    );
  }

  Widget buildInvestDirectionToggle(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    final guideline = getIt<GuidelineProvider>();

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Obx(
          () => InvestmentDirectionToggle(
            value: controller.direction.value,
            activeColor: accentColor,
            onChanged: controller.setDirection,
          ),
        ),
        Obx(() {
          final txCtrl = Get.find<TransactionController>();
          if (!guideline.hasTaskActive('investment') ||
              txCtrl.selectedTabIndex.value !=
                  TransactionTabKind.investment.index) {
            return const SizedBox.shrink();
          }
          return Positioned(
            top: context.respDim(15),
            right: context.respDim(50),
            child: PrjGuidelineBadge(
              size: context.respDim(6),
              label: guideline.bannerDescription,
              labelAbove: false,
              growRight: false,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFormFields(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return CcFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountSection(context, controller, accentColor),
          const CcSpaceSM(),
          Obx(() => _buildWalletSection(context, controller, accentColor)),
          const CcSpaceSM(),
          _buildNewItemSection(context, controller, accentColor),
          Obx(
            () => EntryAdditionalDetailsSection(
              hasExpanded: controller.showMoreDetails.value,
              onToggle: controller.toggleMoreDetails,
              selectedDate: controller.date.value,
              onDateSelected: controller.setDate,
              onCalendarTap: () => controller.pickDate(context),
              noteController: controller.noteController,
              activeColor: accentColor,
            ),
          ),
          const CcSpaceSM(),
          _buildSubmitButton(context, controller, accentColor),
          const CcSpaceXS(),
        ],
      ),
    );
  }

  Widget _buildNewItemSection(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return Obx(() {
      if (controller.hasAddingNewItem.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNewItemNameField(context, controller, accentColor),
            const CcSpaceSM(),
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildSubmitButton(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return Obx(
      () => CcSubmitButton(
        text: el.tr(
          controller.direction.value == InvestmentDirection.contribute
              ? PrjLocaleKeys.transaction_record_investment
              : PrjLocaleKeys.transaction_record_investment_return,
        ),
        hasSubmitting: controller.hasSubmitting.value,
        hasEnabled: controller.canSubmit,
        onTap: () => controller.submitForm(context),
        activeColor: accentColor,
        gradient: context.investmentGoldGradient,
        gradientForegroundColor: context.onInvestmentGold,
        leadingIcon:
            controller.direction.value == InvestmentDirection.contribute
            ? Icons.arrow_circle_down
            : Icons.arrow_circle_up,
        leadingIconSize: 18,
      ),
    );
  }

  Widget _buildNewItemNameField(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    final selectedCat = controller.selectedCategory.value;
    final categoryNameKey = selectedCat?.nameKey ?? '';
    final categoryName = BudgetNameHelper.getDisplayName(
      name: el.tr(categoryNameKey),
      categoryNameKey: categoryNameKey.isNotEmpty ? categoryNameKey : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: el.tr(PrjLocaleKeys.transaction_investment_item)),
        const CcSpaceXS(),
        TextField(
          controller: controller.newItemNameController,
          enabled: controller.quickEntry.hasVip.value,
          onChanged: controller.setNewItemName,
          style: context.ccTextTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: el.tr(PrjLocaleKeys.transaction_new_investment_item_hint),
            border: context.inputBorderTextField,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.respDim(12),
              vertical: context.respDim(10),
            ),
            suffixIcon: !controller.quickEntry.hasVip.value
                ? Tooltip(
                    message: el.tr(
                      PrjLocaleKeys.transaction_investment_item_vip_locked,
                      namedArgs: {'name': categoryName},
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: context.ccColorScheme.outline,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return FormAmountSection(
      controller: controller,
      label: el.tr(PrjLocaleKeys.transaction_amount),
      activeColor: accentColor,
      fieldKey: _amountFieldKey,
    );
  }

  Widget _buildWalletSection(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    final labelKey =
        controller.direction.value == InvestmentDirection.contribute
        ? PrjLocaleKeys.transaction_source_investment
        : PrjLocaleKeys.transaction_destination_investment;
    return FormWalletSection(
      controller: controller,
      label: el.tr(labelKey),
      activeColor: accentColor,
      background: context.investmentGoldCardGradient,
    );
  }

  Widget _buildMoneyKeypadPanel(
    BuildContext context,
    InvestmentFormController controller,
    Color accentColor,
  ) {
    return FormKeypadPanel(controller: controller, activeColor: accentColor);
  }
}
