import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.isLinking = false,
  });

  final VoidCallback onPhoneLogin;

  final String? loginTitle;
  final String? phoneLoginTitle;
  final String? agreeText;
  final String? termsText;
  final bool isLinking;

  @override
  State<LoginCardContent> createState() => _LoginCardContentState();
}

class _LoginCardContentState extends State<LoginCardContent> {
  bool _isAgreed = false;

  /// Set when a login button is tapped before the terms are accepted, so the
  /// terms row turns to the error color instead of the tap doing nothing.
  bool _showAgreeHint = false;

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
    final bool isDisabled = widget.isLinking;
    final double opacity = isDisabled ? 0.3 : (_isAgreed ? 1.0 : 0.5);
    final bool needsAgreement = !isDisabled && !_isAgreed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CcSpaceLG(),
        const CcSpeechBubbleIcon(),
        const CcSpaceLG(),
        CcText(
          widget.isLinking
              ? (widget.loginTitle ?? el.tr(CcLocaleKeys.auth_link_account))
              : (widget.loginTitle ?? el.tr(CcLocaleKeys.auth_login)),
          textStyle: context.ccTextTheme.headlineMedium?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: context.ccColorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const CcSpaceXL(),
        // While the terms are not accepted the buttons stay dimmed, but a tap
        // on them must still respond: it points the user at the terms row.
        // (A silently ignored tap reads as "the button is broken".)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: needsAgreement ? _nudgeTerms : null,
          child: IgnorePointer(
            ignoring: isDisabled || !_isAgreed,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: opacity,
                  child: LoginSocialButtons(isLinking: widget.isLinking),
                ),
                const CcSpaceXL(),
                LoginOrDivider(orText: el.tr(CcLocaleKeys.common_or)),
                const CcSpaceXL(),
                Opacity(
                  opacity: opacity,
                  child: CcBaseBtn(
                    onTap: (isDisabled || !_isAgreed)
                        ? null
                        : widget.onPhoneLogin,
                    title: widget.isLinking
                        ? (widget.phoneLoginTitle ??
                              el.tr(CcLocaleKeys.auth_link_phone))
                        : (widget.phoneLoginTitle ??
                              el.tr(CcLocaleKeys.auth_login_phone)),
                    bgColor: [
                      context.ccColorScheme.primary,
                      context.ccColorScheme.primary,
                    ],
                    textColor: CcBaseColors.white100,
                  ),
                ),
              ],
            ),
          ),
        ),
        const CcSpaceLG(),
        _buildTermsCheckbox(context, isDisabled: isDisabled),
        const CcSpaceLG(),
      ],
    );
  }

  void _nudgeTerms() {
    HapticFeedback.mediumImpact();
    setState(() => _showAgreeHint = true);
  }

  Widget _buildTermsCheckbox(BuildContext context, {required bool isDisabled}) {
    final bool highlight = _showAgreeHint && !_isAgreed;
    final Color? hintColor = highlight ? context.ccColorScheme.error : null;

    return Row(
      children: [
        Checkbox(
          value: _isAgreed,
          isError: highlight,
          onChanged: isDisabled
              ? null
              : (value) => setState(() {
                  _isAgreed = value ?? false;
                  _showAgreeHint = false;
                }),
          activeColor: context.ccColorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: context.brSm),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: widget.agreeText ?? el.tr(CcLocaleKeys.auth_agree_prefix),
              style: context.ccTextTheme.bodySmall?.copyWith(color: hintColor),
              children: [
                TextSpan(
                  text:
                      widget.termsText ??
                      el.tr(CcLocaleKeys.auth_terms_of_service),
                  style: context.ccTextTheme.bodySmall?.copyWith(
                    color: hintColor ?? context.ccColorScheme.primary,
                    fontWeight: CcTypographyParams.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = isDisabled
                        ? null
                        : () {
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
