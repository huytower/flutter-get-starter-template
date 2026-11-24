import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_micro_features/l10n/cc_mf_locale_keys.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/di/di.dart';
import '../../../data/datasources/auth_preference_datasource.dart';
import 'auth_two_column_body.dart';
import 'login_or_divider.dart';
import 'login_social_buttons.dart';

class LoginCardContent extends StatefulWidget {
  const LoginCardContent({
    super.key,
    required this.onPhoneLogin,
    this.loginTitle,
    this.phoneLoginTitle,
    this.hasLinking = false,
  });

  final VoidCallback onPhoneLogin;

  final String? loginTitle;
  final String? phoneLoginTitle;
  final bool hasLinking;

  @override
  State<LoginCardContent> createState() => _LoginCardContentState();
}

class _LoginCardContentState extends State<LoginCardContent> {
  bool _hasAgreed = false;

  /// Set when a login button is tapped before the terms are accepted, so the
  /// terms row turns to the error color instead of the tap doing nothing.
  bool _showAgreeHint = false;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final accepted = await getIt<AuthPreferenceDataSource>().hasTermsAccepted();
    if (mounted && accepted) {
      setState(() => _hasAgreed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDisabled = widget.hasLinking;
    final double opacity = hasDisabled ? 0.3 : (_hasAgreed ? 1.0 : 0.5);
    final bool needsAgreement = !hasDisabled && !_hasAgreed;

    return AuthTwoColumnBody(
      header: [
        const CcSpaceLG(),
        const CcSpeechBubbleIcon(),
        const CcSpaceLG(),
        CcText(
          widget.hasLinking
              ? (widget.loginTitle ?? el.tr(CcMfLocaleKeys.auth_link_account))
              : (widget.loginTitle ?? el.tr(CcMfLocaleKeys.auth_login)),
          textStyle: context.ccTextTheme.headlineMedium?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: context.ccColorScheme.onSurface,
          ),
          // Centred under the logo when the header is its own column.
          align: CcTwoColumn.shouldUse(context) ? Alignment.center : null,
          textAlign: TextAlign.center,
        ),
        const CcSpaceXL(),
      ],
      form: [
        // While the terms are not accepted the buttons stay dimmed, but a tap
        // on them must still respond: it points the user at the terms row.
        // (A silently ignored tap reads as "the button is broken".)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: needsAgreement ? _nudgeTerms : null,
          child: IgnorePointer(
            ignoring: hasDisabled || !_hasAgreed,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: opacity,
                  child: LoginSocialButtons(hasLinking: widget.hasLinking),
                ),
                const CcSpaceXL(),
                LoginOrDivider(orText: el.tr(CcMfLocaleKeys.common_or)),
                const CcSpaceXL(),
                Opacity(
                  opacity: opacity,
                  child: CcBaseButton(
                    onTap: (hasDisabled || !_hasAgreed)
                        ? null
                        : widget.onPhoneLogin,
                    title: widget.hasLinking
                        ? (widget.phoneLoginTitle ??
                              el.tr(CcMfLocaleKeys.auth_link_phone))
                        : (widget.phoneLoginTitle ??
                              el.tr(CcMfLocaleKeys.auth_login_phone)),
                    backgroundColor: [
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
        _buildTermsCheckbox(context, hasDisabled: hasDisabled),
        const CcSpaceLG(),
      ],
    );
  }

  TextSpan _buildLegalLink(
    BuildContext context, {
    required String text,
    required Color? hintColor,
    required VoidCallback? onTap,
  }) {
    return TextSpan(
      text: text,
      style: context.ccTextTheme.bodySmall?.copyWith(
        color: hintColor ?? context.ccColorScheme.primary,
        fontWeight: CcTypographyParams.bold,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }

  void _nudgeTerms() {
    HapticFeedback.mediumImpact();
    setState(() => _showAgreeHint = true);
  }

  Widget _buildTermsCheckbox(BuildContext context, {required bool hasDisabled}) {
    final bool highlight = _showAgreeHint && !_hasAgreed;
    final Color? hintColor = highlight ? context.ccColorScheme.error : null;

    return Row(
      children: [
        Checkbox(
          value: _hasAgreed,
          isError: highlight,
          onChanged: hasDisabled
              ? null
              : (value) => setState(() {
                  _hasAgreed = value ?? false;
                  _showAgreeHint = false;
                }),
          activeColor: context.ccColorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: context.brSm),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: el.tr(CcMfLocaleKeys.auth_agree_prefix),
              style: context.ccTextTheme.bodySmall?.copyWith(color: hintColor),
              children: [
                _buildLegalLink(
                  context,
                  text: el.tr(CcMfLocaleKeys.auth_terms_of_service),
                  hintColor: hintColor,
                  onTap: hasDisabled
                      ? null
                      : () => getIt<AuthCoordinator>().navigateToTerms(context),
                ),
                TextSpan(text: el.tr(CcMfLocaleKeys.auth_terms_privacy_connector)),
                // Separate link so the Privacy Policy is one tap away before
                // sign-in (App Store guideline 5.1.1(i)).
                _buildLegalLink(
                  context,
                  text: el.tr(CcMfLocaleKeys.auth_privacy_policy),
                  hintColor: hintColor,
                  onTap: hasDisabled
                      ? null
                      : () => getIt<AuthCoordinator>().navigateToPrivacyPolicy(
                          context,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
