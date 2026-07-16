import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:cc_sdk_ui/widgets/padding/cc_padding.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../domain/report_range.dart';

class ReportRangeSelector extends StatelessWidget {
  const ReportRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onChanged,
  });

  final ReportRange selectedRange;
  final ValueChanged<ReportRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final primaryBackground = context.ccColorScheme.primary;
    final primaryText = context.ccColorScheme.onPrimary;
    final scheme = context.ccColorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(context.respDim(20)),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withOpacity(0.12),
              blurRadius: context.respDim(12),
              offset: Offset(0, context.respDim(6)),
            ),
          ],
        ),
        padding: EdgeInsets.all(context.respDim(4)),
        child: SegmentedButton<ReportRange>(
          segments: [
            ButtonSegment(
              value: ReportRange.weekly,
              label: Text(el.tr(CcLocaleKeys.report_weekly)),
            ),
            ButtonSegment(
              value: ReportRange.monthly,
              label: Text(el.tr(CcLocaleKeys.report_three_months)),
            ),
            ButtonSegment(
              value: ReportRange.yearly,
              label: Text(el.tr(CcLocaleKeys.report_yearly)),
            ),
          ],
          selected: {selectedRange},
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            backgroundColor: scheme.surface,
            selectedBackgroundColor: primaryBackground,
            selectedForegroundColor: primaryText,
            side: BorderSide(color: primaryBackground.withOpacity(0.1)),
            textStyle: context.ccTextTheme.titleSmall,
          ),
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ),
    );
  }
}
