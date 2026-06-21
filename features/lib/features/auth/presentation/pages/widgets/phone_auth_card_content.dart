import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import 'phone_otp_input.dart';

class PhoneAuthCardContent extends StatelessWidget {
  const PhoneAuthCardContent({
    super.key,
    required this.isCodeSent,
    required this.countryCode,
    required this.phoneController,
    required this.codeController,
    required this.onCountryCodeTap,
    required this.onContinue,
    required this.isLoading,
    required this.errorMessage,
    this.onEditPhoneNumber,
    this.onResendCode,
  });

  final bool isCodeSent;
  final String countryCode;
  final TextEditingController phoneController;
  final TextEditingController codeController;
  final VoidCallback onCountryCodeTap;
  final VoidCallback onContinue;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onEditPhoneNumber;
  final VoidCallback? onResendCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CcSpaceLG(),

        // Speech bubble icon
        const CcSpeechBubbleIcon(),

        const CcSpaceLG(),

        // Title
        CcText(
          isCodeSent
              ? el.tr(CcLocaleKeys.auth_we_just_sent_sms)
              : el.tr(CcLocaleKeys.auth_enter_phone_number),
          maxLines: 2,
          align: Alignment.center,
          textStyle: context.ccTextTheme.headlineMedium?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: context.ccColorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        if (isCodeSent) ...[
          const CcSpaceSM(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CcText(
                '${el.tr(CcLocaleKeys.auth_enter_security_code)}',
                align: Alignment.center,
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CcText(
                    '$countryCode${phoneController.text}',

                    align: Alignment.center,
                    marginLeft: 0,
                    marginRight: 0,
                    textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                      color: context.ccColorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    onPressed: onEditPhoneNumber,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: context.respDim(16),
                      color: context.ccColorScheme.primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],

        const CcSpaceXL(),

        if (!isCodeSent) ...[
          // Phone number input
          CcPhoneNumberInput(
            countryCode: countryCode,
            onCountryCodeTap: onCountryCodeTap,
            controller: phoneController,
            hintText: el.tr(CcLocaleKeys.auth_phone_number_hint),
          ),
        ] else ...[
          // OTP Input boxes
          PhoneOtpInput(
            controller: codeController,
            onCompleted: (_) => onContinue(),
          ),
          const CcSpaceXL(),
        ],

        if (errorMessage != null) ...[
          const CcSpaceMD(),
          CcText(
            el.tr(errorMessage!),
            maxLines: 8,
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: context.ccColorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const CcSpaceMD(),

        // Continue/Verify button
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          CcBaseBtn(
            onTap: onContinue,
            title: isCodeSent
                ? el.tr(CcLocaleKeys.auth_verify)
                : el.tr(CcLocaleKeys.common_continue),
            bgColor: [
              context.ccColorScheme.primary,
              context.ccColorScheme.primary,
            ],
            textColor: context.ccColorScheme.onPrimary,
          ),

        if (isCodeSent) ...[
          const CcSpaceLG(),
          CcText(
            el.tr(CcLocaleKeys.auth_didnt_receive_code),
            align: Alignment.center,
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const CcSpaceXS(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CcText(
                '${el.tr(CcLocaleKeys.auth_resend)} ',
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: context.ccColorScheme.primary,
                  fontWeight: CcTypographyParams.bold,
                ),
              ),
              CcCountDown(
                seconds: 60,
                onTimerFinish: () {
                  // Handle timer finish if needed
                },
                style: context.ccTextTheme.bodyMedium?.copyWith(
                  color: context.ccColorScheme.primary,
                  fontWeight: CcTypographyParams.bold,
                ),
              ),
            ],
          ),
        ],
        const CcSpaceLG(),
      ],
    );
  }
}
