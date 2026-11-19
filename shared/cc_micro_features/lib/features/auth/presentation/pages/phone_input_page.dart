import 'package:cc_micro_features/l10n/cc_mf_locale_keys.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../domain/sms_supported_regions.dart';
import '../bloc/phone_auth_bloc.dart';
import '../bloc/phone_auth_event.dart';
import '../bloc/phone_auth_state.dart';
import 'widgets/auth_security_warning_card.dart';
import 'widgets/auth_two_column_body.dart';
import 'widgets/phone_auth_gradient_container.dart';
import 'widgets/sms_region_picker_sheet.dart';

class PhoneInputPage extends StatefulWidget {
  const PhoneInputPage({super.key});

  @override
  State<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends State<PhoneInputPage> {
  late final TextEditingController _phoneController;
  String _countryCode = defaultSmsDialCode;
  String _countryIsoCode = defaultSmsIsoCode;
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

  Future<void> _pickCountry() async {
    final region = await SmsRegionPickerSheet.show(
      context,
      selectedDialCode: _countryCode,
    );
    if (region == null || !mounted) return;
    setState(() {
      _countryCode = region.dialCode;
      _countryIsoCode = region.isoCode;
      _validationError = null;
    });
  }

  void _handleContinue() {
    // Auto-parse phone number by removing leading zeros
    final parsedPhoneNumber = CcPhoneNumberHelper.autoParsePhoneNumber(
      _countryCode,
      _phoneController.text,
    );

    // Validate the parsed phone number
    if (!getIt<CcPhoneNumberValidator>().isValidMobile(parsedPhoneNumber)) {
      setState(() {
        _validationError = el.tr(CcMfLocaleKeys.validation_phone);
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
    return AuthTwoColumnBody(
      header: [
        const CcSpeechBubbleIcon(),
        CcText(
          el.tr(CcMfLocaleKeys.auth_enter_phone_number),
          maxLines: 2,
          align: Alignment.center,
          textStyle: context.ccTextTheme.headlineMedium?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: context.ccColorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const CcSpaceXL(),
      ],
      form: [
        CcPhoneNumberInput(
          countryCode: _countryCode,
          countryIsoCode: _countryIsoCode,
          onCountryCodeTap: _pickCountry,
          controller: _phoneController,
          hintText: el.tr(CcMfLocaleKeys.auth_phone_number_hint),
        ),
        // Validation error display
        if (_validationError != null)
          Padding(
            padding: EdgeInsets.only(
              top: context.respPadding(CcPaddingParams.DESC_MD),
            ),
            child: CcText(
              _validationError!,
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
                errorMessage,
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
                  title: el.tr(CcMfLocaleKeys.common_continue),
                );
              },
            );
          },
        ),
        const CcSpaceSM(),
        AuthSecurityWarningCard(
          onOtherLoginTap: () => Navigator.of(context).pop(),
        ),
        const CcSpaceMD(),
      ],
    );
  }
}
