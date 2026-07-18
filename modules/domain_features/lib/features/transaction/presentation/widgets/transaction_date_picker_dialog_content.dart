import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class TransactionDatePickerDialogContent extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const TransactionDatePickerDialogContent({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<TransactionDatePickerDialogContent> createState() =>
      _TransactionDatePickerDialogContentState();
}

class _TransactionDatePickerDialogContentState
    extends State<TransactionDatePickerDialogContent> {
  late DateTime _selectedDate;
  late DateTime _viewedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _viewedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  void _previousMonth() {
    setState(() {
      _viewedMonth = DateTime(_viewedMonth.year, _viewedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _viewedMonth = DateTime(_viewedMonth.year, _viewedMonth.month + 1);
    });
  }

  void _onDateTap(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInMonth(DateTime date, DateTime month) {
    return date.year == month.year && date.month == month.month;
  }

  bool get _canGoPrevious {
    return _viewedMonth.year > widget.firstDate.year ||
        (_viewedMonth.year == widget.firstDate.year &&
            _viewedMonth.month > widget.firstDate.month);
  }

  bool get _canGoNext {
    return _viewedMonth.year < widget.lastDate.year ||
        (_viewedMonth.year == widget.lastDate.year &&
            _viewedMonth.month < widget.lastDate.month);
  }

  List<DateTime> _getCalendarDays() {
    final firstDayOfMonth = DateTime(_viewedMonth.year, _viewedMonth.month, 1);
    final lastDayOfMonth = DateTime(
      _viewedMonth.year,
      _viewedMonth.month + 1,
      0,
    );

    final days = <DateTime>[];
    final startWeekday = firstDayOfMonth.weekday;

    for (int i = startWeekday - 1; i > 0; i--) {
      days.add(DateTime(firstDayOfMonth.year, firstDayOfMonth.month, 1 - i));
    }

    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      days.add(DateTime(_viewedMonth.year, _viewedMonth.month, day));
    }

    final remaining = 42 - days.length;
    if (remaining > 0) {
      for (int i = 1; i <= remaining; i++) {
        days.add(
          DateTime(
            lastDayOfMonth.year,
            lastDayOfMonth.month,
            lastDayOfMonth.day + i,
          ),
        );
      }
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final languageCode = Localizations.localeOf(context).languageCode;
    final calendarDays = _getCalendarDays();
    final today = DateTime.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context, scheme, languageCode),
        _buildBody(context, scheme, languageCode, calendarDays, today),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme scheme,
    String languageCode,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primaryContainer],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.respDim(12)),
          topRight: Radius.circular(context.respDim(12)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _canGoPrevious ? _previousMonth : null,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: scheme.onPrimary,
              size: context.respIconSize(baseSize: 18),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: CcText(
              el.DateFormat('MMMM yyyy', languageCode).format(_viewedMonth),
              maxLines: 1,
              align: Alignment.center,
              textStyle: context.ccTextTheme.labelLarge?.copyWith(
                color: scheme.onPrimary,
                fontWeight: CcTypographyParams.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _canGoNext ? _nextMonth : null,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: scheme.onPrimary,
              size: context.respIconSize(baseSize: 18),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ColorScheme scheme,
    String languageCode,
    List<DateTime> calendarDays,
    DateTime today,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.respDim(12)),
          bottomRight: Radius.circular(context.respDim(12)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildWeekdayLabels(context, scheme, languageCode),
          _buildCalendarGrid(context, scheme, calendarDays, today),
          _buildActions(context, scheme),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels(
    BuildContext context,
    ColorScheme scheme,
    String languageCode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(7, (index) {
          final weekday = index + 1;
          final label = el.DateFormat.E(
            languageCode,
          ).format(DateTime(2024, 1, weekday));
          return Expanded(
            child: CcText(
              label,
              align: Alignment.center,
              textStyle: context.ccTextTheme.labelMedium?.copyWith(
                color: scheme.primary.withOpacity(0.8),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    ColorScheme scheme,
    List<DateTime> calendarDays,
    DateTime today,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 40,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 42,
      itemBuilder: (context, index) =>
          _buildDayCell(context, scheme, calendarDays[index], today),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    ColorScheme scheme,
    DateTime date,
    DateTime today,
  ) {
    final isCurrentMonth = _isInMonth(date, _viewedMonth);
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isSameDay(date, today);

    return GestureDetector(
      onTap: () {
        if (date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate)) {
          return;
        }
        _onDateTap(date);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : Colors.transparent,
          borderRadius: context.brLg,
          border: Border.all(
            color: isSelected
                ? scheme.primary
                : isToday
                ? scheme.primary.withOpacity(0.3)
                : Colors.transparent,
            width: isSelected || isToday ? 1.5 : 0,
          ),
        ),
        child: Center(
          child: CcText(
            '${date.day}',
            align: Alignment.center,
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              fontWeight: isSelected
                  ? CcTypographyParams.bold
                  : CcTypographyParams.regular,
              color: isSelected
                  ? scheme.onPrimary
                  : isCurrentMonth
                  ? scheme.onSurface
                  : scheme.onSurfaceVariant.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ColorScheme scheme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.respPadding(CcPaddingParams.PAGE_MD),
        0,
        context.respPadding(CcPaddingParams.PAGE_MD),
        context.respPadding(CcPaddingParams.PAGE_XS),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: CcText(
              el.tr(CcLocaleKeys.common_cancel),
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: scheme.primary,
                fontWeight: CcTypographyParams.semiBold,
              ),
            ),
          ),
          const CcSpaceSM(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selectedDate),
            child: CcText(
              el.tr(CcLocaleKeys.common_ok),
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: scheme.primary,
                fontWeight: CcTypographyParams.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
