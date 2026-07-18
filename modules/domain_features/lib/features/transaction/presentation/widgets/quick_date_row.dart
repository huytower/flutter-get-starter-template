import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

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

    return Row(
      children: [
        CcText(
          el.tr(CcLocaleKeys.transaction_time),
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
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
          child: Icon(
            Icons.calendar_month,
            size: context.respIconSize(baseSize: 18),
            color: scheme.outline,
          ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
          vertical: context.respPadding(CcPaddingParams.SPACE_XS),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: CcBorderRadius.lg(context),
          border: Border.all(
            color: isSelected
                ? activeColor
                : context.ccColorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: CcText(
          label,
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: isSelected
                ? activeColor
                : context.ccColorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
