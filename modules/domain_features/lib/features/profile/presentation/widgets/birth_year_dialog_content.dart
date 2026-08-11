import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class BirthYearDialogContent extends StatefulWidget {
  final int currentYear;
  final int minYear;
  final int maxYear;

  const BirthYearDialogContent({
    super.key,
    required this.currentYear,
    required this.minYear,
    required this.maxYear,
  });

  @override
  State<BirthYearDialogContent> createState() => _BirthYearDialogContentState();
}

class _BirthYearDialogContentState extends State<BirthYearDialogContent> {
  late DateTime _selectedDate;
  late int _selectedYear;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.currentYear;
    _selectedDate = DateTime(
      _selectedYear,
      DateTime.now().month,
      DateTime.now().day,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize scroll controller here since it needs context for respDim
    if (_scrollController == null) {
      // Scroll so the selected year starts roughly in view when opened.
      final int index = _selectedYear - widget.minYear;
      final int row = index ~/ 3;
      _scrollController = ScrollController(
        initialScrollOffset:
            (row - 1).clamp(0, double.infinity) * context.respDim(56),
      );
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  String get _headerDateLabel {
    final languageCode = Localizations.localeOf(context).languageCode;
    return el.DateFormat('EEEE, MMM d', languageCode).format(_selectedDate);
  }

  String get _monthYearLabel {
    final languageCode = Localizations.localeOf(context).languageCode;
    return el.DateFormat('MMMM yyyy', languageCode).format(_selectedDate);
  }

  void _onYearTap(int year) {
    setState(() {
      _selectedYear = year;
      _selectedDate = DateTime(year, _selectedDate.month, _selectedDate.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final int totalYears = widget.maxYear - widget.minYear + 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context, scheme),
        _buildBody(context, scheme, totalYears),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        vertical: context.respPadding(CcPaddingParams.PAGE_SM),
      ),
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
      child: CcText(
        el.tr(CcLocaleKeys.profile_birth_year_hint),
        maxLines: 3,
        textStyle: context.ccTextTheme.labelLarge?.copyWith(
          color: scheme.onPrimary,
          fontWeight: CcTypographyParams.bold,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme scheme, int totalYears) {
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
          _buildYearGrid(context, scheme, totalYears),
          _buildActions(context, scheme),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
        ],
      ),
    );
  }

  Widget _buildYearGrid(
    BuildContext context,
    ColorScheme scheme,
    int totalYears,
  ) {
    return SizedBox(
      height: context.respDim(250),
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
          vertical: context.respPadding(CcPaddingParams.PAGE_SM),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: context.respDim(56),
        ),
        itemCount: totalYears,
        itemBuilder: (context, index) =>
            _buildYearChip(context, scheme, widget.minYear + index),
      ),
    );
  }

  Widget _buildYearChip(BuildContext context, ColorScheme scheme, int year) {
    final bool isSelected = year == _selectedYear;

    return Center(
      child: CcInkWell(
        onTap: () => _onYearTap(year),
        borderRadius: context.brLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: context.respDim(72),
          height: context.respDim(40),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary : Colors.transparent,
            borderRadius: context.brLg,
          ),
          child: CcText(
            '$year',
            align: Alignment.center,
            textStyle: context.ccTextTheme.bodyLarge?.copyWith(
              fontWeight: isSelected
                  ? CcTypographyParams.bold
                  : CcTypographyParams.regular,
              color: isSelected ? scheme.onPrimary : scheme.onSurface,
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
            onPressed: () => Navigator.of(context).pop(_selectedYear),
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
