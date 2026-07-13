import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class BirthYearDialogContent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.ccColorScheme.primary,
                context.ccColorScheme.primaryContainer,
              ],
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.respDim(CcCircularParams.CARD)),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            context.respPadding(CcPaddingParams.PAGE_SM),
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.PAGE_SM),
            context.respPadding(CcPaddingParams.SPACE_MD),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CcText(
                      el.tr(CcLocaleKeys.common_select_date).toUpperCase(),
                      textStyle: context.ccTextTheme.bodySmall?.copyWith(
                        color: context.ccColorScheme.onPrimary,
                        letterSpacing: 1.2,
                        fontWeight: CcTypographyParams.bold,
                      ),
                    ),
                  ),
                  CcIconButton.simple(
                    icon: Icon(
                      Icons.close_rounded,
                      color: context.ccColorScheme.onPrimary,
                      size: context.respIconSize(baseSize: 20),
                    ),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const CcSpaceMD(),
              Divider(
                height: context.respDim(1),
                thickness: context.respDim(1),
                color: context.ccColorScheme.onPrimary.withOpacity(0.16),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.ccColorScheme.surface,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(context.respDim(CcCircularParams.CARD)),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
            vertical: context.respPadding(CcPaddingParams.SPACE_SM),
          ),
          child: SizedBox(
            height: context.respDim(220),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                textTheme: Theme.of(context).textTheme.copyWith(
                  bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.ccColorScheme.onSurface,
                  ),
                ),
              ),
              child: YearPicker(
                firstDate: DateTime(minYear),
                lastDate: DateTime(maxYear),
                selectedDate: DateTime(currentYear),
                onChanged: (date) {
                  Navigator.of(context).pop(date.year);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
