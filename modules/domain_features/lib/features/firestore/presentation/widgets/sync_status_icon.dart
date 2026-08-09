import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../financial_data_sync_service.dart';

/// Cloud sync status affordance: offline (local-only, at risk) vs online
/// with pending items (catching up) vs fully synced. Tapping while online
/// with something pending triggers an immediate sync attempt.
class SyncStatusIcon extends StatelessWidget {
  const SyncStatusIcon({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final service = getIt<FinancialDataSyncService>();
    final color = iconColor ?? context.ccColorScheme.onPrimary;

    return Obx(() {
      final online = service.isOnline.value;
      final pending = service.pendingCount.value;
      final flagged = !online || pending > 0;

      final icon = !online
          ? Icons.cloud_off_rounded
          : pending > 0
          ? Icons.cloud_sync_rounded
          : Icons.cloud_done_rounded;

      final tooltip = !online
          ? el.tr(CcLocaleKeys.sync_offline_tooltip)
          : pending > 0
          ? el.tr(
              CcLocaleKeys.sync_pending_tooltip,
              namedArgs: {'count': '$pending'},
            )
          : el.tr(CcLocaleKeys.sync_synced_tooltip);

      return CcIconButton.bouncing(
        onTap: online ? () => service.syncAll() : () {},
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: context.respIconSize(baseSize: 24), color: color),
            if (flagged)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: context.respDim(10),
                  height: context.respDim(10),
                  decoration: BoxDecoration(
                    color: context.ccColorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.ccColorScheme.surface,
                      width: context.respDim(1),
                    ),
                  ),
                ),
              ),
          ],
        ),
        tooltip: tooltip,
      );
    });
  }
}
