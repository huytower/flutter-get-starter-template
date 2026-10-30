import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../firestore/guest_login_prompt_service.dart';

/// Bottom sheet widget prompting guests to log in with an account.
///
/// Reminds guest users that guest data is stored on this device only and will be
/// replaced when logging in to a cloud account.
class GuestLoginPromptSheet extends StatelessWidget {
  const GuestLoginPromptSheet({
    super.key,
    required this.prompt,
    required this.onCancel,
    required this.onLogin,
  });

  final GuestLoginPrompt prompt;
  final VoidCallback onCancel;
  final VoidCallback onLogin;

  static Future<bool?> show(
    BuildContext context, {
    required GuestLoginPrompt prompt,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => GuestLoginPromptSheet(
        prompt: prompt,
        onCancel: () => Navigator.of(sheetContext).pop(false),
        onLogin: () => Navigator.of(sheetContext).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFinal = prompt == GuestLoginPrompt.finalWarning;
    final scheme = context.ccColorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.respPadding(CcPaddingParams.PAGE_LG),
          context.respPadding(CcPaddingParams.PAGE_LG),
          context.respPadding(CcPaddingParams.PAGE_LG),
          context.respPadding(CcPaddingParams.PAGE_MD),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: context.respDim(64),
                height: context.respDim(64),
                decoration: BoxDecoration(
                  color: (isFinal ? scheme.error : scheme.primary).withOpacity(
                    0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFinal
                      ? Icons.warning_amber_rounded
                      : Icons.cloud_sync_outlined,
                  size: context.respIconSize(baseSize: 32),
                  color: isFinal ? scheme.error : scheme.primary,
                ),
              ),
            ),
            const CcSpaceMD(),
            CcText(
              el.tr(
                isFinal
                    ? CcLocaleKeys.profile_guest_login_final_title
                    : CcLocaleKeys.profile_guest_login_title,
              ),
              align: Alignment.center,
              textStyle: context.ccTextTheme.titleLarge?.copyWith(
                fontWeight: CcTypographyParams.bold,
                color: scheme.onSurface,
              ),
            ),
            const CcSpaceSM(),
            CcText(
              el.tr(
                isFinal
                    ? CcLocaleKeys.profile_guest_login_final_body
                    : CcLocaleKeys.profile_guest_login_body,
              ),
              align: Alignment.center,
              textAlign: TextAlign.center,
              maxLines: 5,
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const CcSpaceXL(),
            Row(
              children: [
                Expanded(
                  child: CcBouncing(
                    onTap: onCancel,
                    borderRadius: BorderRadius.circular(context.respDim(12)),
                    child: Container(
                      height: context.respDim(48),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(
                          context.respDim(12),
                        ),
                      ),
                      child: CcText(
                        el.tr(CcLocaleKeys.common_later),
                        align: Alignment.center,
                        textAlign: TextAlign.center,
                        textStyle: context.ccTextTheme.titleMedium?.copyWith(
                          fontWeight: CcTypographyParams.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const CcSpaceMD(),
                Expanded(
                  child: CcBouncing(
                    onTap: onLogin,
                    borderRadius: BorderRadius.circular(context.respDim(12)),
                    child: Container(
                      height: context.respDim(48),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(
                          context.respDim(12),
                        ),
                      ),
                      child: CcText(
                        el.tr(CcLocaleKeys.common_guest_login_action),
                        align: Alignment.center,
                        textAlign: TextAlign.center,
                        textStyle: context.ccTextTheme.titleMedium?.copyWith(
                          fontWeight: CcTypographyParams.bold,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
