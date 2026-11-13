import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Dismissible reminder explaining why the user should sign in: it keeps their
/// financial data safe. It has no sign-in button on purpose — the profile card
/// above already offers the link actions. Styled like that card (primary
/// gradient with on-primary text).
class ProfileSignInReminder extends StatelessWidget {
  const ProfileSignInReminder({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: context.respPadding(CcPaddingParams.PAGE_SM),
        top: context.respPadding(CcPaddingParams.SPACE_SM),
        bottom: context.respPadding(CcPaddingParams.SPACE_SM),
        right: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primaryContainer],
        ),
        borderRadius: context.brLg,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: context.respPadding(CcPaddingParams.SPACE_XS),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CcText(
                    el.tr(CcLocaleKeys.profile_sign_in_reminder_title),
                    maxLines: 2,
                    textStyle: context.ccTextTheme.titleSmall?.copyWith(
                      fontWeight: CcTypographyParams.bold,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const CcSpaceXS(),
                  CcText(
                    el.tr(CcLocaleKeys.profile_sign_in_reminder_body),
                    maxLines: 4,
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      color: scheme.onPrimary.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded),
            iconSize: context.respIconSize(baseSize: 18),
            color: scheme.onPrimary.withOpacity(0.85),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
