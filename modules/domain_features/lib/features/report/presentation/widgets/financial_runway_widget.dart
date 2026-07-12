import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../domain/entities/financial_runway_entity.dart';

class FinancialRunwayWidget extends StatelessWidget {
  const FinancialRunwayWidget({
    super.key,
    required this.runway,
  });

  final FinancialRunwayEntity runway;

  @override
  Widget build(BuildContext context) {
    final baseStyle = context.ccTextTheme.headlineMedium;
    final targetFontSize = (baseStyle?.fontSize ?? 28) * 0.54;

    final (statusColor, containerColor) = _getStatusColors(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(24),
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
                  size: 20,
                ),
                const SizedBox(width: 8),
                CcText(
                  el.tr(CcLocaleKeys.report_safety_index),
                  textStyle: context.ccTextTheme.labelMedium?.copyWith(
                    color: statusColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (runway.status == FinancialRunwayStatus.insufficient)
            CcText(
              el.tr(CcLocaleKeys.report_runway_not_available),
              textStyle: baseStyle?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w900,
                fontSize: targetFontSize,
              ),
            )
          else
            CcText(
              el.tr(CcLocaleKeys.report_runway_message, namedArgs: {
                'months': runway.months.toString(),
                'days': runway.days.toString(),
              }),
              textStyle: baseStyle?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w900,
                fontSize: targetFontSize,
              ),
            ),
          const SizedBox(height: 12),
          CcText(
            el.tr(runway.message),
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              fontSize: (context.ccTextTheme.bodyMedium?.fontSize ?? 14) * 0.8,
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
        return (
          scheme.primary,
          scheme.primaryContainer.withValues(alpha: 0.4),
        );
      case FinancialRunwayStatus.safe:
        // Use a yellowish/orange color for 'safe' (3-6 months)
        final warningColor = Colors.orange;
        return (
          warningColor,
          warningColor.withValues(alpha: 0.1),
        );
      case FinancialRunwayStatus.caution:
        return (
          scheme.error,
          scheme.errorContainer.withValues(alpha: 0.4),
        );
      case FinancialRunwayStatus.insufficient:
        return (
          scheme.outline,
          scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        );
    }
  }
}
