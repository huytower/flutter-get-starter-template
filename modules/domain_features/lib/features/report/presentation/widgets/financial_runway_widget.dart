import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../domain/entities/financial_runway_entity.dart';

class FinancialRunwayWidget extends StatelessWidget {
  const FinancialRunwayWidget({
    super.key,
    required this.runway,
    this.showChevron = true,
  });

  final FinancialRunwayEntity runway;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);
    final statusIcon = _getStatusIcon(runway.status);
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
        CcListBannerMedium(
          leadingIcon: statusIcon,
          title: message,
          color: statusColor,
          description: runway.fixedMonthlyCost > 0
              ? el.tr(CcLocaleKeys.report_runway_fixed_price_desc)
              : el.tr(CcLocaleKeys.report_runway_no_fixed_price_desc),
          descriptionIcon: runway.fixedMonthlyCost > 0
              ? Icons.bolt_rounded
              : Icons.info_outline_rounded,
          suffixIcon: showChevron ? Icons.chevron_right : null,
          showChevron: false,
        ),
        const CcSpaceSM(),
        _buildDescription(context, el.tr(CcLocaleKeys.report_runway_desc_2)),
      ],
    );
  }

  IconData _getStatusIcon(FinancialRunwayStatus? status) {
    final s = status ?? FinancialRunwayStatus.excellent;
    return switch (s) {
      FinancialRunwayStatus.excellent => Icons.auto_awesome_rounded,
      FinancialRunwayStatus.good => Icons.sentiment_very_satisfied_rounded,
      FinancialRunwayStatus.safe => Icons.shield_rounded,
      FinancialRunwayStatus.caution => Icons.warning_amber_rounded,
      FinancialRunwayStatus.insufficient => Icons.info_outline_rounded,
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
        borderRadius: context.brSm,
      ),
      child: CcText(
        text,
        maxLines: 5,
        textStyle: context.ccTextTheme.labelSmall?.copyWith(
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
