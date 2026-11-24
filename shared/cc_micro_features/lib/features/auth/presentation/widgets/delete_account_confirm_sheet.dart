import 'package:cc_micro_features/l10n/cc_mf_locale_keys.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Confirmation sheet before deleting the signed-in account. Shows which
/// account ([accountLabel]), what deleting means, and, when the account uses
/// Sign in with Apple ([hasAppleSignIn]), that Apple will ask to confirm.
/// Returns `true` when confirmed (after calling [onConfirm]), `false` or
/// `null` otherwise.
///
/// ```dart
/// await DeleteAccountConfirmSheet.show(
///   context,
///   accountLabel: user.email,
///   onConfirm: controller.deleteAccount,
/// );
/// ```
class DeleteAccountConfirmSheet extends StatelessWidget {
  const DeleteAccountConfirmSheet({
    super.key,
    required this.onConfirm,
    this.hasAppleSignIn = false,
    this.accountLabel,
  });

  final VoidCallback onConfirm;

  /// The signed-in account (email, phone or name).
  final String? accountLabel;

  /// Sign in with Apple is linked, so deleting opens Apple's sheet (needed to
  /// revoke the Apple token). Said up front so it is not taken for a sign-in.
  final bool hasAppleSignIn;

  static Future<bool?> show(
    BuildContext context, {
    required VoidCallback onConfirm,
    bool hasAppleSignIn = false,
    String? accountLabel,
  }) {
    return CcAdaptiveBottomSheet.show<bool>(
      context: context,
      backgroundColor: null,
      builder: (_) => DeleteAccountConfirmSheet(
        onConfirm: onConfirm,
        hasAppleSignIn: hasAppleSignIn,
        accountLabel: accountLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = accountLabel;
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
              _buildIcon(context),
              const CcSpaceMD(),
              _buildTitle(context),
              if (label != null && label.isNotEmpty) ...[
                const CcSpaceXS(),
                _buildAccountLabel(context, label),
              ],
              const CcSpaceSM(),
              _buildNote(context, CcMfLocaleKeys.auth_delete_confirm_desc, 5),
              if (hasAppleSignIn) ...[
                const CcSpaceSM(),
                _buildNote(
                  context,
                  CcMfLocaleKeys.auth_delete_apple_note,
                  4,
                  hasSmallText: true,
                ),
              ],
              const CcSpaceLG(),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Center(
      child: Container(
        padding: EdgeInsets.all(context.respDim(14)),
        decoration: BoxDecoration(
          color: scheme.error.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_remove_rounded,
          color: scheme.error,
          size: context.respIconSize(baseSize: 28),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return CcText(
      el.tr(CcMfLocaleKeys.auth_delete_confirm),
      align: Alignment.center,
      textAlign: TextAlign.center,
      textStyle: context.ccTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.ccColorScheme.onSurface,
      ),
    );
  }

  Widget _buildAccountLabel(BuildContext context, String label) {
    return CcText(
      label,
      align: Alignment.center,
      textAlign: TextAlign.center,
      textStyle: context.ccTextTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: context.ccColorScheme.error,
      ),
    );
  }

  Widget _buildNote(
    BuildContext context,
    String key,
    int maxLines, {
    bool hasSmallText = false,
  }) {
    final style = hasSmallText
        ? context.ccTextTheme.bodySmall
        : context.ccTextTheme.bodyMedium;
    return CcText(
      el.tr(key),
      align: Alignment.center,
      maxLines: maxLines,
      textAlign: TextAlign.center,
      textStyle: style?.copyWith(color: context.ccColorScheme.onSurfaceVariant),
    );
  }

  Widget _buildActions(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Row(
      children: [
        Expanded(
          child: CcBaseButton(
            title: MaterialLocalizations.of(context).cancelButtonLabel,
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
            title: el.tr(CcMfLocaleKeys.auth_delete_account),
            backgroundColor: [scheme.error, scheme.error],
            textColor: scheme.onError,
            onTap: () {
              Navigator.of(context).pop(true);
              onConfirm();
            },
          ),
        ),
      ],
    );
  }
}
