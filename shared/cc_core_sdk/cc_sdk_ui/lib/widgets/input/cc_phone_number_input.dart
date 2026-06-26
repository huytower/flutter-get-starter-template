import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../export_cc_sdk_ui.dart';

class CcPhoneNumberInput extends StatelessWidget {
  const CcPhoneNumberInput({
    super.key,
    required this.countryCode,
    required this.onCountryCodeTap,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.phone,
    this.inputFormatters,
  });

  final String countryCode;
  final VoidCallback onCountryCodeTap;
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  static final _defaultFormatters = [FilteringTextInputFormatter.digitsOnly];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CcCountryCodeSelector(
          countryCode: countryCode,
          onTap: onCountryCodeTap,
        ),
        SizedBox(width: context.respPadding(CcPaddingParams.DESC_MD)),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters ?? _defaultFormatters,
            style: context.ccTextTheme.bodyMedium?.copyWith(
              color: context.ccColorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  context.respDim(CcPaddingParams.DESC_SM),
                ),
                borderSide: BorderSide(
                  color: context.ccColorScheme.outline,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  context.respDim(CcPaddingParams.DESC_SM),
                ),
                borderSide: BorderSide(
                  color: context.ccColorScheme.outline,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  context.respDim(CcPaddingParams.DESC_SM),
                ),
                borderSide: BorderSide(
                  color: context.ccColorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.respPadding(CcPaddingParams.DESC_MD),
                vertical: context.respPadding(CcPaddingParams.DESC_MD),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
