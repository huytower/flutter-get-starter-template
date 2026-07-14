import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class BudgetLimitNameInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback onClear;

  const BudgetLimitNameInput({
    super.key,
    required this.controller,
    this.errorText,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: 30,
      decoration: InputDecoration(
        labelText: el.tr(CcLocaleKeys.budget_name),
        hintText: el.tr(CcLocaleKeys.budget_name_hint),
        errorText: errorText,
        suffixIcon: controller.text.isNotEmpty
            ? CcIconButton.bouncing(
                icon: const Icon(Icons.clear, size: 20),
                onTap: onClear,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
