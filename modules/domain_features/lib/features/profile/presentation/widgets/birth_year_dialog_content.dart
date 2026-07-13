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
  static const Color _headerColor = Color(0xFFB98BC9);
  static const Color _bodyColor = Color(0xFFECEAF6);
  static const Color _pillColor = Color(0xFFB98BC9);
  static const Color _accentColor = Color(0xFF9B6FAE);

  late DateTime _selectedDate;
  late int _selectedYear;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.currentYear;
    _selectedDate = DateTime(
      _selectedYear,
      DateTime.now().month,
      DateTime.now().day,
    );

    // Scroll so the selected year starts roughly in view when opened.
    final int index = _selectedYear - widget.minYear;
    final int row = index ~/ 3;
    _scrollController = ScrollController(
      initialScrollOffset: (row - 1).clamp(0, double.infinity) * 56.0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    final int totalYears = widget.maxYear - widget.minYear + 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---- Header ----
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.respPadding(20)),
          decoration: BoxDecoration(
            color: _headerColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(context.respDim(24)),
              topRight: Radius.circular(context.respDim(24)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: CcText(
                  _headerDateLabel,
                  textStyle: context.ccTextTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: context.respFontSize(26),
                    fontWeight: CcTypographyParams.semiBold,
                  ),
                ),
              ),
              CcIconButton.simple(
                icon: Icon(
                  Icons.edit_outlined,
                  color: Colors.white.withOpacity(0.9),
                  size: context.respIconSize(baseSize: 20),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),

        // ---- Body ----
        Container(
          decoration: BoxDecoration(
            color: _bodyColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(context.respDim(24)),
              bottomRight: Radius.circular(context.respDim(24)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---- Month/Year row ----
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.respPadding(20),
                  context.respPadding(16),
                  context.respPadding(20),
                  context.respPadding(4),
                ),
                child: Row(
                  children: [
                    CcText(
                      _monthYearLabel,
                      textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                        fontSize: context.respFontSize(15),
                        fontWeight: CcTypographyParams.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_up,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),

              // ---- Year grid ----
              SizedBox(
                height: context.respDim(250),
                child: GridView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.respPadding(12),
                    vertical: context.respPadding(8),
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: 56,
                  ),
                  itemCount: totalYears,
                  itemBuilder: (context, index) {
                    final int year = widget.minYear + index;
                    final bool isSelected = year == _selectedYear;

                    return Center(
                      child: GestureDetector(
                        onTap: () => _onYearTap(year),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: context.respDim(72),
                          height: context.respDim(40),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? _pillColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              context.respDim(20),
                            ),
                          ),
                          child: CcText(
                            '$year',
                            align: Alignment.center,
                            textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                              fontSize: context.respFontSize(16),
                              fontWeight: isSelected
                                  ? CcTypographyParams.bold
                                  : CcTypographyParams.regular,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ---- Actions ----
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.respPadding(12),
                  context.respPadding(4),
                  context.respPadding(16),
                  context.respPadding(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: CcText(
                        el.tr(CcLocaleKeys.common_cancel),
                        textStyle: context.ccTextTheme.labelLarge?.copyWith(
                          color: _accentColor,
                          fontWeight: CcTypographyParams.semiBold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(_selectedYear),
                      child: CcText(
                        el.tr(CcLocaleKeys.common_ok),
                        textStyle: context.ccTextTheme.labelLarge?.copyWith(
                          color: _accentColor,
                          fontWeight: CcTypographyParams.semiBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
