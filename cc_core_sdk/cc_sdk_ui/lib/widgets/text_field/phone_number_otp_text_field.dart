import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/extensions/cc_context_extension.dart';

class PhoneNumberOtpTextField extends StatelessWidget {
  const PhoneNumberOtpTextField({
    super.key,
    required this.controller,
    this.onChanged,
    this.colorDivider,
  });

  final TextEditingController controller;
  final Function(String)? onChanged;
  final Color? colorDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          textAlign: TextAlign.center,
          style: context.ccTextTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: '******',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: colorDivider ?? context.ccColorScheme.outlineVariant,
        ),
      ],
    );
  }
}
