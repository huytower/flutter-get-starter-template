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

    return Column(
      children: [
        _buildHeader(context),
        const CcSpaceXS(),
        _buildStatusContainer(context, statusColor, containerColor),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return _buildDescription(context, el.tr(CcLocaleKeys.report_runway_desc_2));
  }

  Widget _buildStatusContainer(
    BuildContext context,
    Color statusColor,
    Color containerColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_XS),
        vertical: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(context.respDim(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusMessage(context, statusColor),
          const CcSpaceMD(),
          _buildStatusDetail(context),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(BuildContext context, Color statusColor) {
    final messageStyle = context.ccTextTheme.titleSmall?.copyWith(
      color: statusColor,
      fontWeight: CcTypographyParams.bold,
    );

    final status = runway.status ?? FinancialRunwayStatus.excellent;
    final icon = _getStatusIcon(status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: statusColor,
          size: context.respIconSize(baseSize: 20),
        ),
        const CcSpaceXS(),
        Expanded(
          child: runway.status == FinancialRunwayStatus.insufficient
              ? CcText(
                  el.tr(CcLocaleKeys.report_runway_not_available),
                  maxLines: 2,
                  textStyle: messageStyle,
                )
              : CcText(
                  el.tr(
                    CcLocaleKeys.report_runway_message,
                    namedArgs: {
                      'months': runway.months.toString(),
                      'days': runway.days.toString(),
                    },
                  ),
                  maxLines: 2,
                  textStyle: messageStyle,
                ),
        ),
      ],
    );
  }

  Widget _buildStatusDetail(BuildContext context) {
    return CcText(
      el.tr(runway.message),
      maxLines: 2,
      textStyle: context.ccTextTheme.labelSmall?.copyWith(
        color: context.ccColorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildDescription(BuildContext context, String text) {
    return CcText(
      text,
      maxLines: 5,
      textStyle: context.ccTextTheme.labelSmall?.copyWith(
        color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.5),
        fontSize: context.respFontSize(CcTypographyParams.labelSmall),
      ),
    );
  }

  (Color, Color) _getStatusColors(BuildContext context) {
    final scheme = context.ccColorScheme;
    final status = runway.status ?? FinancialRunwayStatus.excellent;
    switch (status) {
      case FinancialRunwayStatus.excellent:
        return (PrjColors.success, PrjColors.success.withValues(alpha: 0.1));
      case FinancialRunwayStatus.good:
        return (scheme.primary, scheme.primaryContainer.withValues(alpha: 0.4));
      case FinancialRunwayStatus.safe:
        return (PrjColors.info, PrjColors.info.withValues(alpha: 0.1));
      case FinancialRunwayStatus.caution:
        return (scheme.error, scheme.errorContainer.withValues(alpha: 0.4));
      case FinancialRunwayStatus.insufficient:
        return (
          scheme.outline,
          scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        );
    }
  }

  IconData _getStatusIcon(FinancialRunwayStatus status) {
    switch (status) {
      case FinancialRunwayStatus.excellent:
        return Icons.verified_rounded;
      case FinancialRunwayStatus.good:
        return Icons.check_circle_outline_rounded;
      case FinancialRunwayStatus.safe:
        return Icons.shield_outlined;
      case FinancialRunwayStatus.caution:
        return Icons.warning_amber_rounded;
      case FinancialRunwayStatus.insufficient:
        return Icons.info_outline_rounded;
    }
  }
}
