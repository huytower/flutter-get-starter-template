import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Reusable quick date selection row with "Today" and "Yesterday" buttons.
/// State-management agnostic widget - can be used with any state management approach.
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
    return Row(
      children: [
        CcText(
          el.tr(CcLocaleKeys.transaction_time),
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: context.respFontSize(CcTypographyParams.labelMedium),
          ),
        ),
        const Spacer(),
        _buildQuickDateButton(
          context,
          el.tr(CcLocaleKeys.transaction_today),
          DateTime.now(),
        ),
        const CcSpaceSM(),
        _buildQuickDateButton(
          context,
          el.tr(CcLocaleKeys.transaction_yesterday),
          DateTime.now().subtract(const Duration(days: 1)),
        ),
        const CcSpaceSM(),
        GestureDetector(
          onTap: onCalendarTap,
          child: Icon(Icons.calendar_month, size: 18, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildQuickDateButton(
    BuildContext context,
    String label,
    DateTime date,
  ) {
    final isSelected = _isSameDay(selectedDate, date);
    return GestureDetector(
      onTap: () => onDateSelected(date),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: CcText(
          label,
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: isSelected ? activeColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: context.respFontSize(CcTypographyParams.labelMedium),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
