import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../pages/terms_of_service_page.dart';

/// Asks the user to allow sharing data with Google Gemini before any AI
/// feature sends anything. Short on purpose: what is sent, to whom, how to
/// turn it off, plus a link to the Terms & Privacy page.
class AiConsentSheet extends StatelessWidget {
  const AiConsentSheet({super.key});

  /// Returns true when the user has allowed AI data sharing — already stored,
  /// or just granted in the sheet. Declining or dismissing returns false.
  static Future<bool> ensure(BuildContext context) async {
    final prefs = getIt<AiFallbackPreferenceDataSource>();
    if (await prefs.isGeminiEnabled()) return true;
    if (!context.mounted) return false;
    final allowed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AiConsentSheet(),
    );
    final granted = allowed ?? false;
    await prefs.setGeminiEnabled(granted);
    return granted;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return CcLandscapeScrollable(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_LG),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.all(context.respDim(14)),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: scheme.primary,
                    size: context.respIconSize(baseSize: 28),
                  ),
                ),
              ),
              const CcSpaceMD(),
              CcText(
                el.tr(CcLocaleKeys.profile_ai_consent_title),
                align: Alignment.center,
                textAlign: TextAlign.center,
                textStyle: context.ccTextTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const CcSpaceSM(),
              CcText(
                el.tr(CcLocaleKeys.profile_ai_consent_body),
                align: Alignment.center,
                maxLines: 10,
                textAlign: TextAlign.center,
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const CcSpaceSM(),
              CcBouncing(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TermsOfServicePage(),
                  ),
                ),
                child: CcText(
                  el.tr(CcLocaleKeys.profile_ai_consent_terms),
                  align: Alignment.center,
                  textAlign: TextAlign.center,
                  textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                    color: scheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const CcSpaceLG(),
              Row(
                children: [
                  Expanded(
                    child: CcBaseBtn(
                      title: el.tr(CcLocaleKeys.profile_ai_consent_decline),
                      bgColor: [
                        scheme.surfaceContainerHighest,
                        scheme.surfaceContainerHighest,
                      ],
                      textColor: scheme.onSurface,
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const CcSpaceMD(),
                  Expanded(
                    child: CcBaseBtn(
                      title: el.tr(CcLocaleKeys.profile_ai_consent_allow),
                      bgColor: [scheme.primary, scheme.primary],
                      textColor: scheme.onPrimary,
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
