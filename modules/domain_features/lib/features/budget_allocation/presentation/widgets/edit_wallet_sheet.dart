import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../guideline/guideline_controller.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';

/// Bottom sheet for wallet actions (edit/delete).
class EditWalletSheet extends StatelessWidget {
  const EditWalletSheet({
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
      builder: (_) =>
          EditWalletSheet(wallet: wallet, onEdit: onEdit, onDelete: onDelete),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ListTile(
                leading: Icon(Icons.edit_outlined, color: scheme.primary),
                title: CcText(el.tr(CcLocaleKeys.common_edit)),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              if (Get.isRegistered<GuidelineController>())
                Obx(() {
                  final guideline = Get.find<GuidelineController>();
                  final showing =
                      guideline.isTaskActive('wallet_balance') &&
                      wallet.type == WalletType.cash;
                  return Positioned(
                    bottom: 0,
                    right: 0,
                    child: CcGuidelineBadge(
                      showing: showing,
                      color: guideline.currentColor,
                      bounceTrigger: guideline.bounceTrigger,
                      size: 8,
                      label: guideline.bannerDescription,
                    ),
                  );
                }),
            ],
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
