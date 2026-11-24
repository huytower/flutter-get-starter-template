import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

class QuickDateRow extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback? onCalendarTap;
  final Color activeColor;

  const QuickDateRow({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.onCalendarTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    // Wrap (not Row): in a narrow column (tablet two-column form) the quick
    // buttons drop to the next line instead of overflowing.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: context.respDim(8),
      runSpacing: context.respDim(8),
      children: [
        CcText(
          el.tr(PrjLocaleKeys.transaction_time),
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuickDateButton(
              context,
              el.tr(PrjLocaleKeys.transaction_today),
              DateTime.now(),
            ),
            const CcSpaceSM(),
            _buildQuickDateButton(
              context,
              el.tr(PrjLocaleKeys.transaction_yesterday),
              DateTime.now().subtract(const Duration(days: 1)),
            ),
            const CcSpaceSM(),
            CcBouncing(
              onTap: onCalendarTap,
              child: Icon(
                Icons.calendar_month,
                size: context.respIconSize(baseSize: 18),
                color: scheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickDateButton(
    BuildContext context,
    String label,
    DateTime date,
  ) {
    final hasSelected = _isSameDay(selectedDate, date);
    return CcBouncing(
      onTap: () => onDateSelected(date),
      borderRadius: context.brLg,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
          vertical: context.respPadding(CcPaddingParams.SPACE_XS),
        ),
        decoration: BoxDecoration(
          color: hasSelected
              ? activeColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: context.brLg,
          border: Border.all(
            color: hasSelected
                ? activeColor
                : context.ccColorScheme.outlineVariant,
            width: hasSelected ? 1.5 : 1,
          ),
        ),
        child: CcText(
          label,
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: hasSelected
                ? activeColor
                : context.ccColorScheme.onSurfaceVariant,
            fontWeight: hasSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
