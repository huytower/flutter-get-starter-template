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
    final statusColor = _getStatusColor(context);
    final statusIcon = _getStatusIcon(context);
    final message = runway.status == FinancialRunwayStatus.insufficient
        ? el.tr(CcLocaleKeys.report_runway_not_available)
        : el.tr(
            CcLocaleKeys.report_runway_message,
            namedArgs: {
              'months': runway.months.toString(),
              'days': runway.days.toString(),
            },
          );

    return Column(
      children: [
        CcFrostedBanner(
          badgeCount: runway.months,
          message: message,
          accentColor: statusColor,
          icon: statusIcon,
        ),
        const CcSpaceSM(),
        _buildDescription(context, el.tr(CcLocaleKeys.report_runway_desc_2)),
      ],
    );
  }

  Widget _getStatusIcon(BuildContext context) {
    final status = runway.status ?? FinancialRunwayStatus.excellent;
    final size = context.respDim(24);
    final color = context.ccColorScheme.onPrimary;

    return switch (status) {
      FinancialRunwayStatus.excellent => Icon(
        Icons.auto_awesome_rounded,
        size: size,
        color: color,
      ),
      FinancialRunwayStatus.good => Icon(
        Icons.sentiment_very_satisfied_rounded,
        size: size,
        color: color,
      ),
      FinancialRunwayStatus.safe => Icon(
        Icons.shield_rounded,
        size: size,
        color: color,
      ),
      FinancialRunwayStatus.caution => Icon(
        Icons.warning_amber_rounded,
        size: size,
        color: color,
      ),
      FinancialRunwayStatus.insufficient => Icon(
        Icons.info_outline_rounded,
        size: size,
        color: color,
      ),
    };
  }

  Widget _buildDescription(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
        vertical: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.respDim(8)),
      ),
      child: CcText(
        text,
        maxLines: 5,
        textStyle: context.ccTextTheme.labelMedium?.copyWith(
          color: context.ccColorScheme.onPrimary.withOpacity(0.8),
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 1),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    final scheme = context.ccColorScheme;
    final status = runway.status ?? FinancialRunwayStatus.excellent;
    switch (status) {
      case FinancialRunwayStatus.excellent:
        return PrjColors.success;
      case FinancialRunwayStatus.good:
        return scheme.primary;
      case FinancialRunwayStatus.safe:
        return PrjColors.info;
      case FinancialRunwayStatus.caution:
        return scheme.error;
      case FinancialRunwayStatus.insufficient:
        return scheme.outline;
    }
  }
}
