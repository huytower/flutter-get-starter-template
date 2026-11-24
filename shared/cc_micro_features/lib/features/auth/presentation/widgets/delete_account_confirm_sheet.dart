import 'package:cc_micro_features/l10n/cc_mf_locale_keys.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Confirmation before deleting the signed-in account: a [CcConfirmSheet]
/// showing which account ([accountLabel]) and what deleting means. Calls
/// [onConfirm] and returns `true` when confirmed, `false` otherwise.
///
/// ```dart
/// await DeleteAccountConfirmSheet.show(
///   context,
///   accountLabel: user.email,
///   onConfirm: controller.deleteAccount,
/// );
/// ```
abstract final class DeleteAccountConfirmSheet {
  static Future<bool> show(
    BuildContext context, {
    required VoidCallback onConfirm,
    String? accountLabel,
  }) async {
    final confirmed = await CcConfirmSheet.show(
      context,
      icon: Icons.person_remove_rounded,
      title: el.tr(CcMfLocaleKeys.auth_delete_confirm),
      highlight: accountLabel,
      message: el.tr(CcMfLocaleKeys.auth_delete_confirm_desc),
      confirmLabel: el.tr(CcMfLocaleKeys.auth_delete_account),
    );
    if (confirmed) onConfirm();
    return confirmed;
  }
}
