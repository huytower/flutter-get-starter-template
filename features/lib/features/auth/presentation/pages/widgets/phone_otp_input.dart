import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneOtpInput extends StatefulWidget {
  const PhoneOtpInput({
    super.key,
    required this.controller,
    this.length = 6,
    this.onCompleted,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onCompleted;

  @override
  State<PhoneOtpInput> createState() => _PhoneOtpInputState();
}

class _PhoneOtpInputState extends State<PhoneOtpInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hidden TextField to capture input
        Opacity(
          opacity: 0,
          child: SizedBox(
            height: 0,
            width: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              autofocus: true,
              onChanged: (value) {
                if (value.length == widget.length) {
                  widget.onCompleted?.call(value);
                }
              },
            ),
          ),
        ),
        // Visual representation of the OTP boxes
        GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
          },
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(widget.length, (index) {
                  final char = value.text.length > index
                      ? value.text[index]
                      : '';
                  final isFocused =
                      value.text.length == index ||
                      (value.text.length == widget.length &&
                          index == widget.length - 1);

                  return Container(
                    width: context.respDim(35),
                    height: context.respDim(35),
                    decoration: BoxDecoration(
                      color: context.ccColorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        context.respDim(CcPaddingParams.DESC_SM),
                      ),
                      border: Border.all(
                        color: isFocused
                            ? context.ccColorScheme.primary
                            : context.ccColorScheme.outline,
                        width: isFocused ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: CcText(
                      char,
                      align: Alignment.center,
                      textAlign: TextAlign.center,
                      textStyle: context.ccTextTheme.headlineSmall?.copyWith(
                        fontWeight: CcTypographyParams.bold,
                        color: context.ccColorScheme.onSurface,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
