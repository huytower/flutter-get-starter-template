import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../../core/di/di.dart';
import '../../../data/datasources/auth_preference_datasource.dart';
import 'login_or_divider.dart';
import 'login_social_buttons.dart';

class LoginCardContent extends StatefulWidget {
  const LoginCardContent({
    super.key,
    required this.onPhoneLogin,
    this.loginTitle,
    this.phoneLoginTitle,
    this.termsText,
    this.agreeText,
  });

  final VoidCallback onPhoneLogin;

  final String? loginTitle;
  final String? phoneLoginTitle;
  final String? agreeText;
  final String? termsText;

  @override
  State<LoginCardContent> createState() => _LoginCardContentState();
}

class _LoginCardContentState extends State<LoginCardContent> {
  bool _isAgreed = false;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final accepted = await getIt<AuthPreferenceDataSource>().isTermsAccepted();
    if (mounted && accepted) {
      setState(() => _isAgreed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CcSpaceLG(),
        const CcSpeechBubbleIcon(),
        const CcSpaceLG(),
        CcText(
          widget.loginTitle ?? 'Login',
          textStyle: context.ccTextTheme.headlineMedium?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: context.ccColorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const CcSpaceXL(),
        Opacity(
          opacity: _isAgreed ? 1.0 : 0.5,
          child: IgnorePointer(
            ignoring: !_isAgreed,
            child: const LoginSocialButtons(),
          ),
        ),
        const CcSpaceXL(),
        const LoginOrDivider(),
        const CcSpaceXL(),
        Opacity(
          opacity: _isAgreed ? 1.0 : 0.5,
          child: CcBaseBtn(
            onTap: _isAgreed ? widget.onPhoneLogin : null,
            title: widget.phoneLoginTitle ?? 'Login with Phone Number',
            bgColor: [
              context.ccColorScheme.primary,
              context.ccColorScheme.primary,
            ],
            textColor: CcBaseColors.white100,
          ),
        ),
        const CcSpaceLG(),
        _buildTermsCheckbox(context),
        const CcSpaceLG(),
      ],
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _isAgreed,
          onChanged: (value) => setState(() => _isAgreed = value ?? false),
          activeColor: context.ccColorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: context.brSm),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: widget.agreeText ?? 'I agree with ',
              style: context.ccTextTheme.bodySmall,
              children: [
                TextSpan(
                  text: widget.termsText ?? 'Term of Services',
                  style: context.ccTextTheme.bodySmall?.copyWith(
                    color: context.ccColorScheme.primary,
                    fontWeight: CcTypographyParams.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      getIt<AuthCoordinator>().navigateToTerms(context);
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
