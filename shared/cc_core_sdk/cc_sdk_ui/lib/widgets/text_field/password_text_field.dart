import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../divider_line/cc_divider.dart';
import '../flex/cc_flex.dart';
import '../space/cc_space.dart';

class PasswordTextField extends StatelessWidget {
  const PasswordTextField(
    this.hintText, {
    Key? key,
    required this.onChanged,
    required this.onSubmit,
    this.action,
    required this.controller,
    this.hintStyle,
    this.maxLength,
    this.obscureText,
    this.suffix,
    this.textStyle,
  }) : super(key: key);

  final bool? obscureText;

  final Function onChanged, onSubmit;

  final int? maxLength;

  final String? hintText;

  final TextEditingController controller;

  final TextInputAction? action;

  final TextStyle? hintStyle, textStyle;

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
        autofillHints: [AutofillHints.password],
        onChanged: (v) => onChanged(v),
        onFieldSubmitted: (v) => onSubmit(v),
        controller: controller,
        decoration: InputDecoration.collapsed(
          hintText: hintText,
          hintStyle:
              hintStyle ??
              context.ccTextTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.2,
              ),
        ),

        /// Logic : max length = 20
        inputFormatters: [LengthLimitingTextInputFormatter(maxLength ?? 20)],
        obscureText: obscureText ?? true,
        keyboardType: TextInputType.text,
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
