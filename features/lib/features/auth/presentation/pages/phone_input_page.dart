import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/phone_auth_bloc.dart';
import '../bloc/phone_auth_event.dart';
import '../bloc/phone_auth_state.dart';
import 'widgets/phone_auth_gradient_container.dart';

class PhoneInputPage extends StatefulWidget {
  const PhoneInputPage({super.key});

  @override
  State<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends State<PhoneInputPage> {
  late final TextEditingController _phoneController;
  static const String _countryCode = '+84';
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneController.addListener(() {
      // Clear validation error when user types
      if (_validationError != null) {
        setState(() {
          _validationError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    // Auto-parse phone number by removing leading zeros
    final parsedPhoneNumber = CcPhoneNumberHelper.autoParsePhoneNumber(
      _countryCode,
      _phoneController.text,
    );

    // Validate the parsed phone number
    if (!CcPhoneNumberHelper.isValidPhoneNumber(parsedPhoneNumber)) {
      setState(() {
        _validationError = CcLocaleKeys.validation_phone;
      });
      return;
    }

    context.read<PhoneAuthBloc>().add(
      VerifyPhoneNumberStarted(parsedPhoneNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PhoneAuthGradientContainer(child: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: context.isPortrait
            ? context.respDim(500)
            : context.respDim(600),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surface,
        borderRadius: BorderRadius.circular(
          context.respDim(CcPaddingParams.DESC_LG),
        ),
        boxShadow: [
          BoxShadow(
            color: context.ccColorScheme.shadow.withOpacity(0.1),
            blurRadius: context.respDim(20),
            offset: Offset(0, context.respDim(10)),
          ),
        ],
      ),
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_MD)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CcSpaceLG(),
          const CcSpeechBubbleIcon(),
          const CcSpaceLG(),
          CcText(
            el.tr(CcLocaleKeys.auth_enter_phone_number),
            maxLines: 2,
            align: Alignment.center,
            textStyle: context.ccTextTheme.headlineMedium?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: context.ccColorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const CcSpaceXL(),
          CcPhoneNumberInput(
            countryCode: _countryCode,
            onCountryCodeTap: () {},
            controller: _phoneController,
            hintText: el.tr(CcLocaleKeys.auth_phone_number_hint),
          ),
          // Validation error display
          if (_validationError != null)
            Padding(
              padding: EdgeInsets.only(
                top: context.respPadding(CcPaddingParams.DESC_MD),
              ),
              child: CcText(
                el.tr(_validationError!),
                maxLines: 8,
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  color: context.ccColorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          BlocSelector<PhoneAuthBloc, PhoneAuthState, String?>(
            selector: (state) => state is PhoneAuthError ? state.message : null,
            builder: (context, errorMessage) {
              if (errorMessage == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(
                  top: context.respPadding(CcPaddingParams.DESC_MD),
                ),
                child: CcText(
                  el.tr(errorMessage),
                  maxLines: 8,
                  textStyle: context.ccTextTheme.bodySmall?.copyWith(
                    color: context.ccColorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          const CcSpaceMD(),
          BlocSelector<PhoneAuthBloc, PhoneAuthState, bool>(
            selector: (state) => state is PhoneAuthLoading,
            builder: (context, isLoading) {
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: _phoneController,
                builder: (context, value, _) {
                  final bool isNotEmpty = value.text.trim().isNotEmpty;
                  final bool isEnabled = !isLoading && isNotEmpty;

                  return CcNextBtn.bouncing(
                    onTap: _handleContinue,
                    isEnable: isEnabled,
                    title: el.tr(CcLocaleKeys.common_continue),
                  );
                },
              );
            },
          ),
          const CcSpaceLG(),
        ],
      ),
    );
  }
}
