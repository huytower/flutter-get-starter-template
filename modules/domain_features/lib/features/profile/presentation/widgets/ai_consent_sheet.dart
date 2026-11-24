import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../../core/ai/ai_fallback_preference_datasource.dart';
import '../pages/privacy_policy_page.dart';

/// Asks the user to allow sharing data with Google Gemini before any AI
/// feature sends anything. Short on purpose: what is sent, to whom, how to
/// turn it off, plus a link to the Privacy Policy.
abstract final class AiConsentSheet {
  /// Lines the explanation may take.
  static const int _bodyMaxLines = 10;

  /// Returns true when the user has allowed AI data sharing — already stored,
  /// or just granted in the sheet. Declining or dismissing returns false.
  static Future<bool> ensure(
    BuildContext context,
    AiFallbackPreferenceDataSource prefs,
  ) async {
    if (await prefs.hasGeminiEnabled()) return true;
    if (!context.mounted) return false;
    final granted = await CcConfirmSheet.show(
      context,
      icon: Icons.auto_awesome_rounded,
      title: el.tr(PrjLocaleKeys.profile_ai_consent_title),
      message: el.tr(PrjLocaleKeys.profile_ai_consent_body),
      messageMaxLines: _bodyMaxLines,
      extra: const _PrivacyPolicyLink(),
      cancelLabel: el.tr(PrjLocaleKeys.profile_ai_consent_decline),
      confirmLabel: el.tr(PrjLocaleKeys.profile_ai_consent_allow),
      tone: CcConfirmTone.primary,
    );
    await prefs.setGeminiEnabled(granted);
    return granted;
  }
}

/// Underlined link that opens the Privacy Policy over the sheet.
class _PrivacyPolicyLink extends StatelessWidget {
  const _PrivacyPolicyLink();

  @override
  Widget build(BuildContext context) {
    return CcBouncing(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyPage()),
      ),
      child: CcText(
        el.tr(PrjLocaleKeys.profile_ai_consent_terms),
        align: Alignment.center,
        textAlign: TextAlign.center,
        textStyle: context.ccTextTheme.bodyMedium?.copyWith(
          color: context.ccColorScheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
