import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../domain/entities/reconciliation_availability_entity.dart';
import '../helper/audit_day_formatter.dart';

/// Tells the user this audit cycle is already reconciled: when they did it,
/// when the next one opens and is due, and why it waits.
class ReconciliationLockedSheet extends StatelessWidget {
  const ReconciliationLockedSheet({super.key, required this.availability});

  final ReconciliationAvailabilityEntity availability;

  /// True when the user chose to open the page anyway, to look at the history
  /// or undo the last reconciliation.
  static Future<bool> show(
    BuildContext context,
    ReconciliationAvailabilityEntity availability,
  ) async {
    final hasConfirmed = await CcDialogHelper.showMessageBottomSheet(
      context: context,
      title: el.tr(PrjLocaleKeys.reconciliation_locked_title),
      customWidget: ReconciliationLockedSheet(availability: availability),
      confirmText: el.tr(PrjLocaleKeys.reconciliation_locked_got_it),
      cancelText: el.tr(PrjLocaleKeys.reconciliation_locked_view_history),
    );
    // The secondary button ("View history") closes the sheet with false;
    // dragging it away gives null.
    return hasConfirmed == false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final textTheme = context.ccTextTheme;
    final reconciledAt = availability.reconciledAt;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (reconciledAt != null)
          CcText(
            el.tr(
              PrjLocaleKeys.reconciliation_locked_done,
              namedArgs: {'date': AuditDayFormatter.dayWithDate(reconciledAt)},
            ),
            textAlign: TextAlign.center,
            align: Alignment.center,
            textStyle: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        const CcSpaceXS(),
        CcText(
          el.tr(
            PrjLocaleKeys.reconciliation_locked_next,
            namedArgs: {
              'opens': AuditDayFormatter.dayWithDate(availability.nextOpensOn),
              'due': AuditDayFormatter.dayWithDate(availability.nextDueOn),
            },
          ),
          textAlign: TextAlign.center,
          align: Alignment.center,
          textStyle: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: CcTypographyParams.bold,
          ),
        ),
        const CcSpaceMD(),
        CcText(
          el.tr(PrjLocaleKeys.reconciliation_locked_reason),
          maxLines: 6,
          textAlign: TextAlign.center,
          align: Alignment.center,
          textStyle: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
