import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class WeeklyAuditDayDialogContent extends StatefulWidget {
  final int currentDay;

  const WeeklyAuditDayDialogContent({super.key, required this.currentDay});

  @override
  State<WeeklyAuditDayDialogContent> createState() =>
      _WeeklyAuditDayDialogContentState();
}

class _WeeklyAuditDayDialogContentState
    extends State<WeeklyAuditDayDialogContent> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.currentDay;
  }

  void _onDayTap(int day) {
    setState(() {
      _selectedDay = day;
    });
  }

  String _getDayName(int day) {
    // 1 = Monday, ..., 7 = Sunday
    // We can use common_weekday_names which is "Thứ Hai|Thứ Ba|..."
    final names = el.tr(CcLocaleKeys.common_weekday_names).split('|');
    if (day >= 1 && day <= 7) {
      return names[day - 1];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---- Header ----
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_LG),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, scheme.primaryContainer],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(context.respDim(16)),
              topRight: Radius.circular(context.respDim(16)),
            ),
          ),
          child: CcText(
            el.tr(CcLocaleKeys.profile_weekly_audit_day_hint),
            maxLines: 3,
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              color: scheme.onPrimary,
              fontSize: context.respFontSize(14),
              fontWeight: CcTypographyParams.bold,
            ),
          ),
        ),

        // ---- Body ----
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(context.respDim(16)),
              bottomRight: Radius.circular(context.respDim(16)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---- Day grid ----
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
                  vertical: context.respPadding(CcPaddingParams.PAGE_SM),
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: context.respDim(44),
                  crossAxisSpacing: context.respDim(8),
                  mainAxisSpacing: context.respDim(8),
                ),
                itemCount: 7,
                itemBuilder: (context, index) {
                  final int day = index + 1;
                  final bool isSelected = day == _selectedDay;

                  return Center(
                    child: GestureDetector(
                      onTap: () => _onDayTap(day),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: context.respDim(64),
                        height: context.respDim(32),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? scheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            context.respDim(16),
                          ),
                          border: Border.all(
                            color: isSelected
                                ? scheme.primary
                                : scheme.outline.withOpacity(0.1),
                          ),
                        ),
                        child: CcText(
                          _getDayName(day),
                          align: Alignment.center,
                          textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                            fontSize: context.respFontSize(13),
                            fontWeight: isSelected
                                ? CcTypographyParams.bold
                                : CcTypographyParams.regular,
                            color: isSelected
                                ? scheme.onPrimary
                                : scheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ---- Actions ----
              Padding(
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
                    SizedBox(width: context.respDim(8)),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(_selectedDay),
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
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
            ],
          ),
        ),
      ],
    );
  }
}
