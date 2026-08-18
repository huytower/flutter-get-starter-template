import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../domain/entities/liability_entity.dart';
import '../get_x/liability_detail_controller.dart';

/// Hero card atop [LiabilityDetailPage]: outstanding balance plus principal/status
/// chips, tinted by [accentColor] (borrow vs. lend).
///
/// Reads [controller]'s Rx fields directly rather than wrapping itself in its
/// own [Obx] — it's always built inside the page's single top-level `Obx`,
/// whose reactive tracking already covers reads made by nested widgets built
/// synchronously in the same pass.
class LiabilityBalanceCard extends StatelessWidget {
  final LiabilityDetailController controller;
  final LiabilityEntity current;
  final Color accentColor;

  const LiabilityBalanceCard({
    super.key,
    required this.controller,
    required this.current,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accentColor, accentColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            el.tr(CcLocaleKeys.liability_remaining_balance),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
          const CcSpaceMD(),
          CcText(
            '${TransactionFormHelpers.formatAmount(controller.outstandingBalance.value.toString())} đ',
            textStyle: context.ccTextTheme.headlineMedium?.copyWith(
              color: context.ccColorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const CcSpaceMD(),
          Wrap(
            spacing: context.respDim(8),
            children: [
              _LoanBalanceChip(
                label: el.tr(CcLocaleKeys.liability_principal_amount),
                value:
                    '${TransactionFormHelpers.formatAmount(current.principalAmount.toString())} đ',
              ),
              _LoanBalanceChip(
                label: el.tr(
                  current.isBorrow
                      ? CcLocaleKeys.transaction_liability_direction_borrow
                      : CcLocaleKeys.transaction_liability_direction_lend,
                ),
                value: el.tr(
                  controller.isSettled
                      ? CcLocaleKeys.liability_status_settled
                      : CcLocaleKeys.liability_status_outstanding,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoanBalanceChip extends StatelessWidget {
  final String label;
  final String value;

  const _LoanBalanceChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
        vertical: context.respPadding(CcPaddingParams.SPACE_SM),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.onPrimary.withOpacity(0.15),
        borderRadius: context.brSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CcText(
            label,
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: context.ccColorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
          CcText(
            value,
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: context.ccColorScheme.onPrimary,
              fontWeight: CcTypographyParams.bold,
            ),
          ),
        ],
      ),
    );
  }
}


