import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../get_x/wallet_controller.dart';
import '../../domain/entities/wallet_entity.dart';

class WalletDeleteConfirmSheet extends StatelessWidget {
  const WalletDeleteConfirmSheet({
    super.key,
    required this.wallet,
    required this.onDelete,
    required this.onOutcome,
  });

  final WalletEntity wallet;
  final Future<WalletDeleteOutcome> Function() onDelete;
  final void Function(WalletDeleteOutcome) onOutcome;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return SafeArea(
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
                  Icons.delete_outline_rounded,
                  color: scheme.error,
                  size: context.respIconSize(baseSize: 28),
                ),
              ),
            ),
            const CcSpaceMD(),
            CcText(
              el.tr(CcLocaleKeys.wallet_delete_title),
              align: Alignment.center,
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const CcSpaceSM(),
            CcText(
              el.tr(CcLocaleKeys.wallet_delete_confirm_msg),
              align: Alignment.center,
              maxLines: 5,
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const CcSpaceLG(),
            Row(
              children: [
                Expanded(
                  child: CcBaseBtn(
                    title: el.tr(CcLocaleKeys.common_cancel),
                    bgColor: [
                      scheme.surfaceContainerHighest,
                      scheme.surfaceContainerHighest,
                    ],
                    textColor: scheme.onSurface,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: context.respDim(12)),
                Expanded(
                  child: CcBaseBtn(
                    title: el.tr(CcLocaleKeys.common_delete),
                    bgColor: [scheme.error, scheme.error],
                    textColor: scheme.onError,
                    onTap: () async {
                      Navigator.of(context).pop();
                      final outcome = await onDelete();
                      onOutcome(outcome);
                    },
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
