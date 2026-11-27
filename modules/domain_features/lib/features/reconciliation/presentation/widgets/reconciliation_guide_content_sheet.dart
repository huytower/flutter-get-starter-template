import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../../core/presentation/widgets/highlighted_guide_row.dart';
import '../../domain/entities/reconciliation_availability_entity.dart';
import '../helper/audit_day_formatter.dart';

/// Content of the reconciliation guide sheet: the guide rows (icon + text) in a
/// [CcPickerSheetFrame] with a single OK button.
class ReconciliationGuideContentSheet extends StatelessWidget {
  const ReconciliationGuideContentSheet({super.key, this.cycle});

  /// The user's current audit cycle, for the "when" row; null while it has not
  /// loaded, then the row explains the cycle without dates.
  final ReconciliationAvailabilityEntity? cycle;

  /// What reconciliation is, then how to do it (count -> compare -> record).
  /// The last row, when it is due, is [_cycleText].
  static const List<({IconData icon, String textKey})> _items = [
    (
      icon: Icons.info_outline_rounded,
      textKey: PrjLocaleKeys.reconciliation_description_line_1,
    ),
    (
      icon: Icons.sync_alt_rounded,
      textKey: PrjLocaleKeys.reconciliation_description_line_2,
    ),
    (
      icon: Icons.paid_outlined,
      textKey: PrjLocaleKeys.reconciliation_guide_count,
    ),
    (
      icon: Icons.balance_rounded,
      textKey: PrjLocaleKeys.reconciliation_guide_compare,
    ),
    (
      icon: Icons.menu_book_rounded,
      textKey: PrjLocaleKeys.reconciliation_guide_record,
    ),
  ];

  /// One reconciliation per 7-day cycle ending on the user's audit day, with
  /// the current cycle's dates when they are known.
  String _cycleText() {
    final cycle = this.cycle;
    if (cycle == null) return tr(PrjLocaleKeys.reconciliation_cycle_subtitle);
    return tr(
      PrjLocaleKeys.reconciliation_cycle_current,
      namedArgs: {
        'day': AuditDayFormatter.weekday(cycle.cycleEnd),
        'start': AuditDayFormatter.dayWithDate(cycle.cycleStart),
        'end': AuditDayFormatter.dayWithDate(cycle.cycleEnd),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // The rows scroll when they do not fit; the title and OK stay in view.
    return CcPickerSheetFrame(
      title: tr(PrjLocaleKeys.reconciliation_title),
      hasScrollableBody: true,
      body: _buildGuideList(context),
      hasCancel: false,
      onConfirm: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildGuideList(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_MD)),
      child: _buildItems(context),
    );
  }

  Widget _buildItems(BuildContext context) {
    final items = [
      for (final item in _items)
        HighlightedGuideRow(icon: item.icon, text: tr(item.textKey)),
      HighlightedGuideRow(
        icon: Icons.event_repeat_rounded,
        text: _cycleText(),
      ),
    ];
    // Small tablet and up (>= 600 dp window): two columns, so the sheet is
    // wider and shorter instead of one long column.
    if (context.windowSizeClass.hasAtLeast(CcWindowSizeClass.medium)) {
      return CcMultiColumn(
        columns: 2,
        columnGap: context.respPadding(CcPaddingParams.SPACE_LG),
        rowGap: context.respPadding(CcPaddingParams.SPACE_MD),
        children: items,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, item) in items.indexed) ...[
          if (index > 0) const CcSpaceMD(),
          item,
        ],
      ],
    );
  }
}
