import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/cc_form_label.dart';
import '../../../transaction/presentation/widgets/transaction_additional_details_section.dart';
import '../../../transaction/presentation/widgets/transaction_submit_button.dart';
import '../../../wallet/presentation/widgets/cc_wallet_strip_card.dart';
import '../../domain/entities/liability_entity.dart';
import '../get_x/liability_detail_controller.dart';

/// Trả nợ/Thu nợ (repay/collect) form shown on [LiabilityDetailPage] while the
/// loan still has an outstanding balance.
class LiabilityRepayForm extends StatelessWidget {
  final LiabilityDetailController controller;
  final LiabilityEntity current;
  final Color accentColor;

  const LiabilityRepayForm({
    super.key,
    required this.controller,
    required this.current,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcAmountInputSection(
          label: el.tr(CcLocaleKeys.transaction_amount),
          amountStr: controller.amountStr.value,
          quickAmounts: MoneyConstants.quickAmounts,
          isKeypadVisible: controller.showKeypad.value,
          activeColor: accentColor,
          fieldKey: controller.amountFieldKey,
          onTap: () => controller.showKeypadAndScroll(context),
          onQuickAmountSelected: (amount) =>
              controller.amountStr.value = amount.toString(),
          onClear: () => controller.amountStr.value = '0',
          onCopy: () => CcStringHelper.copyToClipboard(controller.amountStr.value),
        ),
        const CcSpaceLG(),
        CcFormLabel(text: el.tr(CcLocaleKeys.transaction_source_debt)),
        const CcSpaceXS(),
        CcWalletStripCard(
          wallets: controller.wallets,
          selectedWalletId: controller.selectedWalletId.value,
          activeColor: accentColor,
          onWalletSelected: controller.setWalletId,
        ),
        const CcSpaceLG(),
        TransactionAdditionalDetailsSection(
          isExpanded: controller.showMoreDetails.value,
          onToggle: controller.toggleMoreDetails,
          selectedDate: controller.date.value,
          onDateSelected: controller.setDate,
          onCalendarTap: () => controller.pickDate(context),
          noteController: controller.noteController,
          hasNoteText: controller.noteController.text.isNotEmpty,
          activeColor: accentColor,
        ),
        const CcSpaceXL(),
        TransactionSubmitButton(
          text: el.tr(
            current.isBorrow
                ? CcLocaleKeys.transaction_record_repay
                : CcLocaleKeys.transaction_record_collect,
          ),
          isSubmitting: controller.isSubmitting.value,
          isEnabled: controller.canSubmit,
          onTap: () => controller.submitForm(context),
          activeColor: accentColor,
        ),
      ],
    );
  }
}


