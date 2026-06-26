import 'package:cc_sdk/core/constants/cc_number_format_params.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../divider_line/cc_divider.dart';
import '../flex/cc_flex.dart';
import '../space/cc_space.dart';

class PhoneNumberTextField extends StatelessWidget {
  const PhoneNumberTextField(
    this.hintText, {
    Key? key,
    required this.onChanged,
    required this.onSubmit,
    this.action,
    required this.controller,
    this.formatter,
    this.hintStyle,
    this.keyboardType,
    this.maxLength,
    this.suffix,
    this.textStyle,
  }) : super(key: key);

  final Function onChanged, onSubmit;

  final int? maxLength;
  final String? formatter, hintText;

  final TextInputAction? action;
  final TextEditingController controller;
  final TextStyle? hintStyle, textStyle;
  final TextInputType? keyboardType;

  final Widget? suffix;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: CcColStart(
      children: [
        /// Section : Edit text
        getEditTextWidget(context),

        const CcSpaceSM(),

        /// Section : Line
        const CcDividerLine(),
      ],
    ),
  );

  Widget getEditTextWidget(BuildContext context) => Stack(
    children: [
      /// Section : Edit text
      TextFormField(
        autofillHints: [AutofillHints.username],
        controller: controller,
        onChanged: (v) => onChanged(v),
        onFieldSubmitted: (v) => onSubmit(v),
        decoration: InputDecoration.collapsed(
          hintText: hintText,
          hintStyle:
              hintStyle ??
              context.ccTextTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.2,
              ),
        ),

        /// Logic : max length = 12, included space
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength ?? 12),
          MaskTextInputFormatter(
            mask: formatter ?? CcNumberFormatParams.PHONE_NUMBER_VN,
            filter: {'#': RegExp(r'[0-9]')},
          ),
        ],
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        style:
            textStyle ?? context.ccTextTheme.titleMedium?.copyWith(height: 1.2),
        textInputAction: action ?? TextInputAction.next,
      ),

      /// Section : Icon
      Positioned(
        bottom: 0,
        right: 0,
        top: 0,
        child: suffix ?? const SizedBox(),
      ),
    ],
  );
}
