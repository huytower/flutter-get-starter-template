import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

class BudgetLimitNameInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback onClear;
  final VoidCallback? onTap;

  const BudgetLimitNameInput({
    super.key,
    required this.controller,
    this.errorText,
    required this.onClear,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CcNameInputField(
      controller: controller,
      hintText: el.tr(PrjLocaleKeys.budget_name_hint),
      errorText: errorText,
      onClear: onClear,
      onTap: onTap,
      maxLength: 30,
      maxLengthWarningText: el.tr(
        PrjLocaleKeys.validation_max_length_reached,
        namedArgs: {'count': '30'},
      ),
    );
  }
}
