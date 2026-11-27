import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../../core/presentation/widgets/highlighted_guide_row.dart';
import '../../domain/entities/reconciliation_availability_entity.dart';
import '../helper/audit_day_formatter.dart';

/// Tells the user this audit cycle is already reconciled: when they did it,
/// when the next one opens and is due, why it waits and how to do it sooner,
/// as bullets styled like the reconciliation guide.
class ReconciliationLockedSheet extends StatelessWidget {
  const ReconciliationLockedSheet({super.key, required this.availability});

  final ReconciliationAvailabilityEntity availability;

  /// True when the user chose to open the page anyway, to look at the history;
  /// false when they only closed the sheet.
  static Future<bool> show(
    BuildContext context,
    ReconciliationAvailabilityEntity availability,
  ) async {
    final hasChosenHistory = await CcAdaptiveBottomSheet.show<bool>(
      context: context,
      backgroundColor: null,
      builder: (_) => ReconciliationLockedSheet(availability: availability),
    );
    return hasChosenHistory ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // The rows scroll when they do not fit; the title and actions stay.
    return CcPickerSheetFrame(
      title: el.tr(PrjLocaleKeys.reconciliation_locked_title),
      hasScrollableBody: true,
      cancelLabel: el.tr(PrjLocaleKeys.reconciliation_locked_view_history),
      onCancel: () => Navigator.of(context).pop(true),
      confirmLabel: el.tr(PrjLocaleKeys.reconciliation_locked_got_it),
      onConfirm: () => Navigator.of(context).pop(false),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_MD)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, bullet) in _bullets().indexed) ...[
              if (index > 0) const CcSpaceMD(),
              HighlightedGuideRow(icon: bullet.icon, text: bullet.text),
            ],
          ],
        ),
      ),
    );
  }

  List<({IconData icon, String text})> _bullets() {
    final reconciledAt = availability.reconciledAt;
    return [
      if (reconciledAt != null)
        (
          icon: Icons.check_circle_outline_rounded,
          text: el.tr(
            PrjLocaleKeys.reconciliation_locked_done,
            namedArgs: {'date': AuditDayFormatter.dayWithDate(reconciledAt)},
          ),
        ),
      (
        icon: Icons.event_available_rounded,
        text: el.tr(
          PrjLocaleKeys.reconciliation_locked_next,
          namedArgs: {
            'opens': AuditDayFormatter.dayWithDate(availability.nextOpensOn),
            'due': AuditDayFormatter.dayWithDate(availability.nextDueOn),
          },
        ),
      ),
      (
        icon: Icons.event_repeat_rounded,
        text: el.tr(PrjLocaleKeys.reconciliation_locked_reason),
      ),
      (
        icon: Icons.edit_calendar_rounded,
        text: el.tr(PrjLocaleKeys.reconciliation_locked_sooner),
      ),
    ];
  }
}
