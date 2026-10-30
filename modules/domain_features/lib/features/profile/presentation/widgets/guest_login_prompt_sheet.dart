import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../budget_allocation/presentation/widgets/budget_insight_card.dart';
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

    final bullet1Key = isFinal
        ? CcLocaleKeys.profile_guest_login_final_bullet1
        : CcLocaleKeys.profile_guest_login_bullet1;
    final bullet2Key = isFinal
        ? CcLocaleKeys.profile_guest_login_final_bullet2
        : CcLocaleKeys.profile_guest_login_bullet2;
    final bullet3Key = isFinal
        ? CcLocaleKeys.profile_guest_login_final_bullet3
        : CcLocaleKeys.profile_guest_login_bullet3;

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
                  color: scheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFinal
                      ? Icons.workspace_premium_outlined
                      : Icons.cloud_outlined,
                  size: context.respIconSize(baseSize: 32),
                  color: scheme.primary,
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
              maxLines: 3,
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.titleLarge?.copyWith(
                fontWeight: CcTypographyParams.bold,
                color: scheme.onSurface,
              ),
            ),
            const CcSpaceLG(),
            Column(
              children: [
                _buildInsightCard(
                  context: context,
                  textKey: bullet1Key,
                  icon: isFinal
                      ? Icons.stars_outlined
                      : Icons.thumb_up_alt_outlined,
                  color: PrjColors.info,
                  scheme: scheme,
                ),
                _buildInsightCard(
                  context: context,
                  textKey: bullet2Key,
                  icon: Icons.warning_amber_rounded,
                  color: scheme.error,
                  scheme: scheme,
                ),
                _buildInsightCard(
                  context: context,
                  textKey: bullet3Key,
                  icon: Icons.info_outline_rounded,
                  color: PrjColors.info,
                  scheme: scheme,
                ),
              ],
            ),
            const CcSpaceMD(),
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
                        el.tr(
                          isFinal
                              ? CcLocaleKeys.common_guest_login_continue_local
                              : CcLocaleKeys.common_later,
                        ),
                        align: Alignment.center,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        textStyle: context.ccTextTheme.labelLarge?.copyWith(
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
                        textStyle: context.ccTextTheme.labelLarge?.copyWith(
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

  Widget _buildInsightCard({
    required BuildContext context,
    required String textKey,
    required IconData icon,
    required Color color,
    required ColorScheme scheme,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: context.respDim(10)),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: context.brLg,
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: context.respDim(80),
            child: CustomPaint(painter: GridPatternPainter(color: color)),
          ),
          Padding(
            padding: EdgeInsets.all(context.respDim(12)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.respDim(8)),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: context.respIconSize(baseSize: 18),
                  ),
                ),
                const CcSpaceMD(),
                Expanded(
                  child: CcText(
                    el.tr(textKey),
                    maxLines: 4,
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
                      height: 1.4,
                      fontWeight: CcTypographyParams.medium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
