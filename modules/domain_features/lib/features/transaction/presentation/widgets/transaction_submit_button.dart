import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class TransactionSubmitButton extends StatelessWidget {
  final String text;
  final bool isSubmitting;
  final bool isEnabled;
  final VoidCallback onTap;
  final Color activeColor;

  const TransactionSubmitButton({
    super.key,
    required this.text,
    required this.isSubmitting,
    required this.isEnabled,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return CcBaseBtn(
      title: text,
      onTap: isEnabled && !isSubmitting ? onTap : null,
      isEnable: isEnabled && !isSubmitting,
      allowShowLoading: isSubmitting,
      bgColor: [activeColor, activeColor],
      width: double.infinity,
    );
  }
}
