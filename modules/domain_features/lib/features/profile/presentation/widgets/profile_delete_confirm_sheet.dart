import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';
import '../../../../core/presentation/helper/adaptive_bottom_sheet.dart';

class ProfileDeleteConfirmSheet extends StatelessWidget {
  const ProfileDeleteConfirmSheet({
    super.key,
    required this.onConfirm,
    this.hasAppleSignIn = false,
    this.accountLabel,
  });

  final VoidCallback onConfirm;

  /// The signed-in account (email, phone or name), so the user can see which
  /// account is about to be deleted.
  final String? accountLabel;

  /// The account has Sign in with Apple linked, so deleting it opens the Apple
  /// sheet to confirm (needed to revoke the Apple token). Said up front so the
  /// Apple sheet is not mistaken for a sign-in.
  final bool hasAppleSignIn;

  static Future<bool?> show(
    BuildContext context, {
    required VoidCallback onConfirm,
    bool hasAppleSignIn = false,
    String? accountLabel,
  }) {
    return showAdaptiveBottomSheet<bool>(
      context: context,
      backgroundColor: null,
      builder: (_) => ProfileDeleteConfirmSheet(
        onConfirm: onConfirm,
        hasAppleSignIn: hasAppleSignIn,
        accountLabel: accountLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    // Scrolls in landscape (short window) instead of overflowing.
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
                    color: scheme.error.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_remove_rounded,
                    color: scheme.error,
                    size: context.respIconSize(baseSize: 28),
                  ),
                ),
              ),
              const CcSpaceMD(),
              CcText(
                el.tr(PrjLocaleKeys.profile_delete_confirm),
                align: Alignment.center,
                textAlign: TextAlign.center,
                textStyle: context.ccTextTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              if (accountLabel != null && accountLabel!.isNotEmpty) ...[
                const CcSpaceXS(),
                CcText(
                  accountLabel!,
                  align: Alignment.center,
                  textAlign: TextAlign.center,
                  textStyle: context.ccTextTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.error,
                  ),
                ),
              ],
              const CcSpaceSM(),
              CcText(
                el.tr(PrjLocaleKeys.profile_delete_confirm_desc),
                align: Alignment.center,
                maxLines: 5,
                textAlign: TextAlign.center,
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (hasAppleSignIn) ...[
                const CcSpaceSM(),
                CcText(
                  el.tr(PrjLocaleKeys.profile_delete_apple_note),
                  align: Alignment.center,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  textStyle: context.ccTextTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const CcSpaceLG(),
              Row(
                children: [
                  Expanded(
                    child: CcBaseButton(
                      title: el.tr(PrjLocaleKeys.common_cancel),
                      backgroundColor: [
                        scheme.surfaceContainerHighest,
                        scheme.surfaceContainerHighest,
                      ],
                      textColor: scheme.onSurface,
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const CcSpaceMD(),
                  Expanded(
                    child: CcBaseButton(
                      title: el.tr(PrjLocaleKeys.profile_delete_account),
                      backgroundColor: [scheme.error, scheme.error],
                      textColor: scheme.onError,
                      onTap: () {
                        Navigator.of(context).pop(true);
                        onConfirm();
                      },
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
