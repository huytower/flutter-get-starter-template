import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:domain_features/core/presentation/widgets/cc_amount_input_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/transaction_form_controller.dart';

/// The amount field every entry form shows: the tappable amount, quick-amount
/// chips, clear and copy. Wires [CcAmountInputSection] to [controller], so a
/// form only chooses its [label] and [activeColor].
///
/// ```dart
/// FormAmountSection(controller: c, label: 'Amount', activeColor: color, fieldKey: key)
/// ```
class FormAmountSection extends StatelessWidget {
  const FormAmountSection({
    super.key,
    required this.controller,
    required this.label,
    required this.activeColor,
    required this.fieldKey,
  });

  final TransactionFormController controller;
  final String label;
  final Color activeColor;
  final GlobalKey fieldKey;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CcAmountInputSection(
        label: label,
        amountStr: controller.amountStr.value,
        quickAmounts: controller.quickAmounts,
        isKeypadVisible: controller.showKeypad.value,
        activeColor: activeColor,
        currencyCode: controller.currencyCode.value,
        fieldKey: fieldKey,
        onTap: () =>
            controller.showKeypadAndScroll(context, fieldKey: fieldKey),
        onQuickAmountSelected: controller.handleSuggestion,
        onClear: controller.handleClear,
        onCopy: () =>
            CcStringHelper.copyToClipboard(controller.amountStr.value),
      ),
    );
  }
}
