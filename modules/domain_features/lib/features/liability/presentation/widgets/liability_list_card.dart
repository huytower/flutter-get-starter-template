import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../../domain/entities/liability_entity.dart';

/// One row in [LiabilityBalanceList] — a loan's counterparty/category, direction
/// and status badges, and remaining-vs-principal balance.
class LiabilityListCard extends StatelessWidget {
  final LiabilityBalanceEntity balance;
  final VoidCallback? onTap;

  const LiabilityListCard({super.key, required this.balance, this.onTap});

  @override
  Widget build(BuildContext context) {
    final loan = balance.liability;
    final isSettled = balance.status == LiabilityStatus.settled;
    final directionColor = loan.isBorrow
        ? PrjColors.warning
        : context.ccColorScheme.secondary;

    return CcBouncing(
      onTap: onTap ?? () {},
      child: CcSymmetricPadding(
        horizontal: CcPaddingParams.SPACE_LG,
        vertical: CcPaddingParams.SPACE_MD,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                context.respPadding(CcPaddingParams.SPACE_SM),
              ),
              decoration: BoxDecoration(
                color: directionColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconDataFromCode(
                  loan.categoryIconCode ?? 0,
                  fontFamily: loan.categoryIconFamily,
                ),
                size: context.respIconSize(baseSize: 22),
                color: directionColor,
              ),
            ),
            const CcSpaceMD(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CcText(
                  '${TransactionFormHelpers.formatAmount(balance.outstandingBalance.toString())} đ',
                  textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSettled
                        ? context.ccColorScheme.onSurfaceVariant
                        : context.ccColorScheme.onSurface,
                  ),
                ),
                CcText(
                  el.tr(CcLocaleKeys.liability_remaining_balance),
                  textStyle: context.ccTextTheme.labelSmall?.copyWith(
                    color: context.ccColorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadges(
    BuildContext context,
    LiabilityEntity loan,
    bool isSettled,
    Color directionColor,
  ) {
    return Wrap(
      spacing: context.respDim(6),
      children: [
        _buildBadge(
          context,
          text: el.tr(
            loan.isBorrow
                ? CcLocaleKeys.transaction_liability_direction_borrow
                : CcLocaleKeys.transaction_liability_direction_lend,
          ),
          color: directionColor,
        ),
        _buildBadge(
          context,
          text: el.tr(
            isSettled
                ? CcLocaleKeys.liability_status_settled
                : CcLocaleKeys.liability_status_outstanding,
          ),
          color: isSettled ? PrjColors.success : context.ccColorScheme.error,
        ),
      ],
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(8),
        vertical: context.respPadding(2),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: context.brSm,
      ),
      child: CcText(
        text,
        textStyle: context.ccTextTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
