import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/util/money_format.dart';
import '../../domain/entities/reconciliation_entity.dart';

/// Summary card for a past reconciliation in the history list.
class ReconciliationHistoryCard extends StatelessWidget {
  final ReconciliationEntity reconciliation;

  const ReconciliationHistoryCard({super.key, required this.reconciliation});

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final balanced = reconciliation.isBalanced;
    final diff = reconciliation.difference;

    return Container(
      margin: EdgeInsets.only(bottom: context.respDim(12)),
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(context.respDim(16)),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CcText(
                el.tr(
                  CcLocaleKeys.reconciliation_week,
                  namedArgs: {
                    'week': reconciliation.week.toString(),
                    'year': reconciliation.year.toString(),
                  },
                ),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                  fontSize: context.respFontSize(CcTypographyParams.titleSmall),
                ),
              ),
              CcText(
                '${reconciliation.date.day}/${reconciliation.date.month}/${reconciliation.date.year}',
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: context.respFontSize(CcTypographyParams.bodySmall),
                ),
              ),
            ],
          ),
          const CcSpaceSM(),
          _row(
            context,
            el.tr(CcLocaleKeys.reconciliation_book),
            formatVndWithSymbol(reconciliation.systemTotal),
          ),
          _row(
            context,
            el.tr(CcLocaleKeys.reconciliation_actual),
            formatVndWithSymbol(reconciliation.actualTotal),
          ),
          const CcSpaceXS(),
          CcText(
            balanced
                ? el.tr(CcLocaleKeys.reconciliation_balanced)
                : el.tr(
                    diff > 0
                        ? CcLocaleKeys.reconciliation_surplus
                        : CcLocaleKeys.reconciliation_deficit,
                    namedArgs: {'amount': formatVndWithSymbol(diff.abs())},
                  ),
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              color: balanced ? scheme.primary : scheme.error,
              fontWeight: CcTypographyParams.bold,
              fontSize: context.respFontSize(CcTypographyParams.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CcText(
            label,
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              fontSize: context.respFontSize(CcTypographyParams.bodySmall),
            ),
          ),
          CcText(
            value,
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              fontSize: context.respFontSize(CcTypographyParams.bodySmall),
            ),
          ),
        ],
      ),
    );
  }
}
