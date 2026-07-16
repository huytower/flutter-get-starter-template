import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../wallet/domain/entities/wallet_entity.dart';

/// Bottom sheet for wallet actions (edit/delete).
class WalletActionsBottomSheet extends StatelessWidget {
  const WalletActionsBottomSheet({
    required this.wallet,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final WalletEntity wallet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static Future<void> show(
    BuildContext context, {
    required WalletEntity wallet,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => WalletActionsBottomSheet(
        wallet: wallet,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit_outlined, color: scheme.primary),
            title: CcText(el.tr(CcLocaleKeys.common_edit)),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: scheme.error),
            title: CcText(
              el.tr(CcLocaleKeys.common_delete),
              textStyle: TextStyle(color: scheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
