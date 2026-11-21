import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/di/di.dart';
import 'package:domain_features/core/presentation/widgets/entry_additional_details_section.dart';
import 'package:domain_features/core/presentation/widgets/entry_form_container.dart';
import 'package:domain_features/core/presentation/widgets/entry_form_two_column.dart';
import 'package:domain_features/core/presentation/widgets/entry_submit_button.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';
import 'package:theme/export_theme.dart';

import '../../../guideline/presentation/widgets/prj_guideline_badge.dart';
import '../../../transaction/presentation/get_x/transaction_controller.dart';
import '../../../transaction/presentation/widgets/form_amount_section.dart';
import '../../../transaction/presentation/widgets/form_keypad_panel.dart';
import '../../../transaction/presentation/widgets/form_wallet_section.dart';
import '../get_x/borrow_form_controller.dart';
import '../get_x/liability_base_form_controller.dart';
import 'borrow_asset_selector.dart';
import 'borrow_direction_toggle.dart';
import 'liability_repayment_method_section.dart';
import 'outstanding_exceeded_hint.dart';

class BorrowForm extends StatefulWidget {
  const BorrowForm({super.key});

  @override
  State<BorrowForm> createState() => _BorrowFormState();
}

class _BorrowFormState extends State<BorrowForm> {
  late final BorrowFormController controller;
  final GlobalKey _amountFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = Get.find<BorrowFormController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.loadSuggestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pre-registered by TransactionController.onInit()
    return Obx(() {
      final isIncrease =
          controller.action.value == LiabilityDirectionForm.increase;
      final accentColor = isIncrease
          ? context.borrowAccent
          : context.borrowAccent.secondaryShade;

      return Column(
        children: [
          Expanded(
            child: _buildScrollableContent(context, controller, accentColor),
          ),
          if (controller.showKeypad.value)
            _buildMoneyKeypadPanel(context, controller, accentColor),
        ],
      );
    });
  }

  Widget _buildScrollableContent(
    BuildContext context,
    BorrowFormController controller,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        controller.hideKeypad();
      },
      child: SingleChildScrollView(
        controller: controller.scrollController,
        child: EntryFormTwoColumn.shouldUse(context)
            ? _buildTwoColumnContent(context, controller, accentColor)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBorrowDirectionToggle(context, controller, accentColor),
                  const CcSpaceSM(),
                  _buildInitiateSection(context, controller, accentColor),
                ],
              ),
      ),
    );
  }

  /// Landscape tablet: direction toggle, liability selector and date/note on
  /// the left; amount, wallet, repayment method and submit on the right.
  Widget _buildTwoColumnContent(
    BuildContext context,
    BorrowFormController controller,
    Color accentColor,
  ) {
    return EntryFormTwoColumn(
      leading: [
        _buildBorrowDirectionToggle(context, controller, accentColor),
        const CcSpaceSM(),
        BorrowAssetSelector(controller: controller, activeColor: accentColor),
        // Repayment method + due date sit in the wide left column, between
        // the category and the time section, so they never overflow.
        Padding(
          padding: EdgeInsets.only(
            left: context.respPadding(CcPaddingParams.PAGE_SM),
            top: context.respPadding(CcPaddingParams.SPACE_SM),
          ),
          child: _buildRepaymentMethodSection(controller, accentColor),
        ),
      ],
      details: EntryAdditionalDetailsSection(
        isExpanded: true,
        selectedDate: controller.date.value,
        onDateSelected: controller.setDate,
        onCalendarTap: () => controller.pickDate(context),
        noteController: controller.noteController,
        activeColor: accentColor,
      ),
      right: [
        Obx(() => _buildAmountSection(context, controller, accentColor)),
        Obx(
          () => OutstandingExceededHint(visible: controller.exceedsOutstanding),
        ),
        const CcSpaceSM(),
        Obx(() => _buildWalletSection(context, controller, accentColor)),
        const CcSpaceSM(),
        _buildSubmitButton(context, controller, accentColor),
        const CcSpaceXS(),
      ],
    );
  }

  Widget _buildRepaymentMethodSection(
    BorrowFormController controller,
    Color accentColor,
  ) {
    return Obx(() {
      if (controller.action.value == LiabilityDirectionForm.decrease) {
        return const SizedBox.shrink();
      }
      return Column(
        children: [
          LiabilityRepaymentMethodSection(
            controller: controller,
            accentColor: accentColor,
          ),
          const CcSpaceSM(),
        ],
      );
    });
  }

  Widget _buildBorrowDirectionToggle(
    BuildContext context,
    BorrowFormController controller,
    Color accentColor,
  ) {
    final guideline = getIt<GuidelineProvider>().isAvailable
        ? getIt<GuidelineProvider>()
        : null;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        BorrowDirectionToggle(
          value: controller.action.value,
          activeColor: accentColor,
          onChanged: controller.setAction,
        ),
        if (guideline != null)
          Obx(() {
            final txCtrl = Get.isRegistered<TransactionController>()
                ? Get.find<TransactionController>()
                : null;
            if (txCtrl == null ||
                !guideline.isTaskActive('liability') ||
                txCtrl.selectedTabIndex.value !=
                    TransactionTabKind.borrow.index) {
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

  Widget _buildInitiateSection(
    BuildContext context,
    BorrowFormController controller,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BorrowAssetSelector(controller: controller, activeColor: accentColor),
        const CcSpaceSM(),
        EntryFormContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => _buildAmountSection(context, controller, accentColor)),
              Obx(
                () => OutstandingExceededHint(
                  visible: controller.exceedsOutstanding,
                ),
              ),
              const CcSpaceSM(),
              Obx(() => _buildWalletSection(context, controller, accentColor)),
              const CcSpaceSM(),
              _buildRepaymentMethodSection(controller, accentColor),
              EntryAdditionalDetailsSection(
                isExpanded: controller.showMoreDetails.value,
                onToggle: controller.toggleMoreDetails,
                selectedDate: controller.date.value,
                onDateSelected: controller.setDate,
                onCalendarTap: () => controller.pickDate(context),
                noteController: controller.noteController,
                activeColor: accentColor,
              ),
              const CcSpaceSM(),
              _buildSubmitButton(context, controller, accentColor),
              const CcSpaceXS(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(
    BuildContext context,
    BorrowFormController controller,
    Color accentColor,
  ) {
    final liability = controller.mergedItems
        .firstWhereOrNull(
          (b) => b.liability.id == controller.selectedLiabilityId.value,
        )
        ?.liability;

    final isRepay = controller.action.value == LiabilityDirectionForm.decrease;

    final label =
        (isRepay || (liability != null && liability.principalAmount > 0))
        ? el.tr(CcLocaleKeys.transaction_amount)
        : el.tr(CcLocaleKeys.transaction_liability_amount_borrow_label);

    return FormAmountSection(
      controller: controller,
      label: label,
      activeColor: accentColor,
      fieldKey: _amountFieldKey,
    );
  }

  Widget _buildWalletSection(
    BuildContext context,
    BorrowFormController controller,
    Color accentColor,
  ) {
    final isRepay = controller.action.value == LiabilityDirectionForm.decrease;
    final text = isRepay
        ? el.tr(CcLocaleKeys.transaction_source_debt)
        : el.tr(CcLocaleKeys.transaction_liability_wallet_borrow_label);

    return FormWalletSection(
      controller: controller,
      label: text,
      activeColor: accentColor,
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    BorrowFormController controller,
    Color accentColor,
  ) {
    final isRepay = controller.action.value == LiabilityDirectionForm.decrease;
    final liability = controller.mergedItems
        .firstWhereOrNull(
          (b) => b.liability.id == controller.selectedLiabilityId.value,
        )
        ?.liability;

    final String text;
    final IconData icon;

    if (isRepay) {
      text = el.tr(CcLocaleKeys.transaction_record_repay);
      icon = Icons.arrow_circle_down;
    } else {
      text = (liability != null && liability.principalAmount > 0)
          ? el.tr(CcLocaleKeys.transaction_record_liability) // Borrow more
          : el.tr(
              CcLocaleKeys.transaction_liability_direction_borrow,
            ); // Initiate
      icon = Icons.arrow_circle_up;
    }

    return EntrySubmitButton(
      text: text,
      isSubmitting: controller.isSubmitting.value,
      isEnabled: controller.canSubmit,
      onTap: () => controller.submitForm(context),
      activeColor: accentColor,
      leadingIcon: icon,
      leadingIconSize: 18,
    );
  }

  Widget _buildMoneyKeypadPanel(
    BuildContext context,
    BorrowFormController controller,
    Color accentColor,
  ) {
    return FormKeypadPanel(controller: controller, activeColor: accentColor);
  }
}
