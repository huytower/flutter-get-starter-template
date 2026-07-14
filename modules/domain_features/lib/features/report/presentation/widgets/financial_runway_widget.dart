import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../domain/entities/financial_runway_entity.dart';

class FinancialRunwayWidget extends StatelessWidget {
  const FinancialRunwayWidget({super.key, required this.runway});

  final FinancialRunwayEntity runway;

  @override
  Widget build(BuildContext context) {
    final (statusColor, containerColor) = _getStatusColors(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
        vertical: context.respPadding(CcPaddingParams.SPACE_LG),
      ),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(context.respDim(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (runway.status != FinancialRunwayStatus.insufficient) ...[
            Row(
              children: [
                Icon(
                  runway.status == FinancialRunwayStatus.caution
                      ? Icons.warning_amber_rounded
                      : Icons.shield_outlined,
                  color: statusColor,
                  size: context.respIconSize(baseSize: 20),
                ),
                SizedBox(width: context.respDim(8)),
                CcText(
                  el.tr(CcLocaleKeys.report_safety_index),
                  textStyle: context.ccTextTheme.labelMedium?.copyWith(
                    color: statusColor.withValues(alpha: 0.8),
                    fontWeight: CcTypographyParams.bold,
                    fontSize: context.respFontSize(
                      CcTypographyParams.labelMedium,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.respDim(16)),
          ],
          if (runway.status == FinancialRunwayStatus.insufficient)
            CcText(
              el.tr(CcLocaleKeys.report_runway_not_available),
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: statusColor,
                fontWeight: CcTypographyParams.bold,
                fontSize: context.respFontSize(CcTypographyParams.titleMedium),
              ),
            )
          else
            CcText(
              el.tr(
                CcLocaleKeys.report_runway_message,
                namedArgs: {
                  'months': runway.months.toString(),
                  'days': runway.days.toString(),
                },
              ),
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: statusColor,
                fontWeight: CcTypographyParams.bold,
                fontSize: context.respFontSize(CcTypographyParams.titleMedium),
              ),
            ),
          SizedBox(height: context.respDim(12)),
          CcText(
            el.tr(runway.message),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              fontSize: context.respFontSize(CcTypographyParams.labelMedium),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _getStatusColors(BuildContext context) {
    final scheme = context.ccColorScheme;
    final status = runway.status ?? FinancialRunwayStatus.excellent;
    switch (status) {
      case FinancialRunwayStatus.excellent:
      case FinancialRunwayStatus.good:
        return (scheme.primary, scheme.primaryContainer.withValues(alpha: 0.4));
      case FinancialRunwayStatus.safe:
        // Use a yellowish/orange color for 'safe' (3-6 months)
        final warningColor = PrjColors.warning;
        return (warningColor, warningColor.withValues(alpha: 0.1));
      case FinancialRunwayStatus.caution:
        return (scheme.error, scheme.errorContainer.withValues(alpha: 0.4));
      case FinancialRunwayStatus.insufficient:
        return (
          scheme.outline,
          scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        );
    }
  }
}
