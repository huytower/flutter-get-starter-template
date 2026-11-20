import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../guideline/export_guideline.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../../core/helper/adaptive_bottom_sheet.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/di/di.dart';

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
    return showAdaptiveBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      backgroundColor: context.ccColorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: context.brXl),
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
              if (getIt<GuidelineProvider>().isAvailable)
                Obx(() {
                  final guideline = getIt<GuidelineProvider>();
                  final showing =
                      guideline.isTaskActive('wallet_balance') &&
                      wallet.type == WalletType.cash;
                  return Positioned(
                    top: context.respDim(-10),
                    right: context.respDim(-10),
                    child: PrjGuidelineBadge(
                      showing: showing,
                      size: context.respDim(8),
                      label: guideline.bannerDescription,
                      growRight: false,
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
