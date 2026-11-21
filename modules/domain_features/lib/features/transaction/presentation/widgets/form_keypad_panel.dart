import 'package:domain_features/core/presentation/widgets/money_keypad_panel.dart';
import 'package:flutter/material.dart';

import '../get_x/transaction_form_controller.dart';

/// The money keypad shown under every entry form. Wires [MoneyKeypadPanel] to
/// [controller]; borrow and lend route keys to an installment draft through
/// the controller's own `handleKeyPress` / `handleClear` overrides.
class FormKeypadPanel extends StatelessWidget {
  const FormKeypadPanel({
    super.key,
    required this.controller,
    required this.activeColor,
  });

  final TransactionFormController controller;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return MoneyKeypadPanel(
      onKeyPress: controller.handleKeyPress,
      onDelete: controller.handleDelete,
      onClear: controller.handleClear,
      suggestions: controller.quickAmounts,
      onSuggestion: controller.handleSuggestion,
      onDone: controller.hideKeypad,
      activeColor: activeColor,
    );
  }
}
